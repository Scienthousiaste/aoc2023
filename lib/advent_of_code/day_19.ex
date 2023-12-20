defmodule AdventOfCode.Day19 do

  @starting_ranges %{"x" => [1..4000], "m" => [1..4000], "a" => [1..4000], "s" => [1..4000]}

  @spec input(any()) :: binary()
  def input(test \\ false) do
    if test do
      """
      px{a<2006:qkq,m>2090:A,rfg}
      pv{a>1716:R,A}
      lnx{m>1548:A,A}
      rfg{s<537:gd,x>2440:R,A}
      qs{s>3448:A,lnx}
      qkq{x<1416:A,crn}
      crn{x>2662:A,R}
      in{s<1351:px,qqz}
      qqz{s>2770:qs,m<1801:hdj,R}
      gd{a>3333:R,R}
      hdj{m>838:A,pv}

      {x=787,m=2655,a=1222,s=2876}
      {x=1679,m=44,a=2067,s=496}
      {x=2036,m=264,a=79,s=2244}
      {x=2461,m=1339,a=466,s=291}
      {x=2127,m=1623,a=2188,s=1013}
      """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_19_input.txt")
      contents
    end
  end

  def parse_rule(rule) do
    if String.contains?(rule, ":") do
      %{"dim" => dim, "op" => op, "val" => val, "next_state" => next_state} =
        Regex.named_captures(
          ~r/(?<dim>[xmas])(?<op>[><])(?<val>\d*):(?<next_state>[a-zA-Z]*)/,
          rule
        )

      %{
        type: :go_if,
        dim: dim,
        op: op,
        val: String.to_integer(val),
        goto: next_state
      }
    else
      %{
        type: :go,
        goto: rule
      }
    end
  end

  def accepted?(wf, p) do
    Enum.reduce_while(1..10000, wf["in"], fn _i, cur ->
      Enum.reduce_while(cur, nil, fn rule, n ->
        case rule.type do
          :go ->
            case rule.goto do
              "R" -> {:halt, {:halt, false}}
              "A" -> {:halt, {:halt, true}}
              w -> {:halt, {:cont, wf[w]}}
            end

          :go_if ->
            follow_rule? =
              case rule.op do
                "<" -> p[rule.dim] < rule.val
                ">" -> p[rule.dim] > rule.val
              end

            if follow_rule? do
              case rule.goto do
                "R" -> {:halt, {:halt, false}}
                "A" -> {:halt, {:halt, true}}
                w -> {:halt, {:cont, wf[w]}}
              end
            else
              {:cont, n}
            end
        end
      end)
    end)
  end

  def parse_workflow(line) do
    %{"name" => name, "rules" => raw_rules} =
      Regex.named_captures(~r/(?<name>[a-z]*){(?<rules>.*)}/, line)

    rules =
      raw_rules
      |> String.split(",")
      |> Enum.map(&parse_rule/1)

    {name, rules}
  end

  def parse_parts(line) do
    line
    |> String.replace(["{", "}"], "")
    |> String.split(",")
    |> Enum.map(fn x ->
      [letter, n] = String.split(x, "=")

      {letter, String.to_integer(n)}
    end)
    |> Map.new()
  end

  def parse() do
    [raw_workflows, raw_parts] =
      input()
      |> String.split("\n\n", trim: true)

    workflows =
      raw_workflows
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_workflow/1)
      |> Map.new()

    parts =
      raw_parts
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_parts/1)

    {workflows, parts}
  end

  def part1(_args \\ []) do
    {workflows, parts} = parse()

    parts
    |> Enum.filter(&accepted?(workflows, &1))
    |> Enum.map(&Map.values(&1))
    |> List.flatten()
    |> Enum.sum()
  end

  def regroup_by_letter(c) do
    ["x", "m", "a", "s"]
    |> Enum.reduce(%{}, fn letter, map ->
      constraints_now = c
      |> Enum.filter(fn {letter_c, _op, _val} -> letter_c == letter end)
      Map.put(map, letter, constraints_now)
    end)
  end

  def update_ranges(ranges, _constraints) do
    # qqz{s>2770:qs,m<1801:hdj,R}

    ranges
  end

  def compute_combinations(constraints, _ranges) do
    cc = constraints
    |> regroup_by_letter

    # On reconmpte plein de fois la même chose je présume,
    # il faut réussir à éliminer des range de possibilités sur le long terme
    # Au début : 1..4000 possible pour chaque lettre, puis au fur et à mesure
    # beaucoup moins
    res = Enum.reduce(["x", "m", "a", "s"], 1, fn l, res ->
        constraints = cc[l]
        inf = Enum.filter([{l, "<", 4000} | constraints], fn {_, op, _} ->
          op == "<"
        end)
        |> Enum.map(fn {_, _, v} -> v end)
        |> Enum.min

        sup = Enum.filter([{l, ">", 1} | constraints], fn {_, op, _} ->
          op == ">"
        end)
        |> Enum.map(fn {_, _, v} -> v end)
        |> Enum.max

        s = Enum.max([0, inf - sup - 1])
        IO.inspect("Letter #{l}, current res #{res}, #{inf}, #{sup} #{s}")
        Enum.max([0, inf - sup - 1]) * res
      end)

    require IEx; IEx.pry
    # |> Enum.reduce(start_combinations, fn {letter, op, val}, combinations ->
      # {"a", ">", 3333},

    res

    # end)
  end


  def part2(_args \\ []) do
    {workflows, _parts} = parse()

    rejection_constraints = propagate(workflows, workflows["in"], [])

    rejection_constraints
    |> List.flatten
    |> Enum.reduce({0, [], @starting_ranges}, fn c, {sum, current_constraints, ranges} ->
      case c do
        :R -> {sum, [], update_ranges(ranges, current_constraints)}
        :A -> {sum + compute_combinations(current_constraints, ranges), [], update_ranges(ranges, current_constraints)}
        const -> {sum, [const | current_constraints], update_ranges(ranges, current_constraints)}
      end
    end)
  end

  def propagate(workflows, rules, constraints) do
    Enum.map(rules, fn rule ->
      case rule.type do
        :go ->
          case rule.goto do
            "R" -> [:R | constraints] |> Enum.reverse
            "A" -> [:A | constraints] |> Enum.reverse
            w -> propagate(workflows, workflows[w], constraints)
          end

        :go_if ->
          new_constraint = {rule.dim, rule.op, rule.val}
          case rule.goto do
            "R" -> [:R | [new_constraint | constraints]] |> Enum.reverse
            "A" -> [:A | [new_constraint | constraints]] |> Enum.reverse
            w -> propagate(workflows, workflows[w], [new_constraint | constraints])
          end
      end
    end)
  end
end
