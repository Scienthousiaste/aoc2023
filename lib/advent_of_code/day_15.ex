defmodule AdventOfCode.Day15 do
  def input(test \\ false) do
    if (test) do
    """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_15_input.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> List.first
    |> String.split(",")
  end

  def hash(str) do
    str
    |> String.to_charlist
    |> Enum.reduce(0, fn ascii, cur ->
      rem((cur + ascii) * 17, 256)
    end)
  end

  def compute_focusing_power(boxes) do
    Enum.reduce(0..255, 0, fn x, sum ->
      r = boxes[x]
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn {{_lb, focus}, idx}, ssum ->
        ssum + idx * focus * (x + 1)
      end)

      sum + r
    end)
  end

  def part1(_args \\ []) do
    parse()
    |> Enum.map(&hash/1)
    |> Enum.sum
  end

  def part2(_args \\ []) do
    boxes = Enum.reduce(0..255, %{}, fn x, map ->
      Map.put(map, x, [])
    end)

    res = parse()
    |> Enum.reduce(boxes, fn line, state ->
      %{"label" => label, "op" => op} = Regex.named_captures(~r/(?<label>\w*)(?<op>[-=]\d?)/, line)
      box = hash(label)
      alabel = String.to_atom(label)

      if op == "-" do
        Map.update(state, box, [], fn box_content ->
          Enum.reduce(box_content, [], fn {lb, focus}, st ->
            if lb == alabel do
              st
            else
              st ++ [{lb, focus}]
            end
          end)
        end)
      else
        focus = String.split(op, "=", trim: true)
        |> List.first
        |> String.to_integer

        Map.update(state, box, [], fn box_content ->
          Keyword.update(box_content, alabel, focus, fn _ex -> focus end)
        end)
      end
    end)

    compute_focusing_power(res)
  end
end
