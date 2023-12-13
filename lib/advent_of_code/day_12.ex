defmodule AdventOfCode.Day12 do
  def input(test \\ false) do
    if test do
      """
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
      """
      # ????.######..#####. 1,6,5

      # ?###???????? 3,2,1
      #  Résultats corrects:
      # ???.### 1,1,3
      # ?? 1
      # ?##..?#?#?? 2,4
      #  ?#?#?#?#?#?#?#? 1,3,1,6
      # ????.#...#... 4,1,1

      # """
      # #
      # # ??????#??#?? 1,1,5,1
      # # ?#?#??##?#? 2,5,1
      # # ????????.?#???#??##? 2,1,2,1,1,6
      # # ???#?????.?#?. 2,1,2,1
      # """
    else
      # AdventOfCode.Input.get!(12, 2023)
      {:ok, contents} = File.read("lib/advent_of_code/day_12_input.txt")
      require IEx; IEx.pry
      contents
    end
  end

  def parse_lines(lines) do
    Enum.reduce(lines, [], fn line, list ->
      [l, r] = String.split(line)
      # {String.split(l, ".", trim: true), String.split(r, ",")}
      # garder la string à droite c'est plus simple à traiter après...
      nums = String.split(r, ",") |> Enum.map(&String.to_integer(&1))
      [{l, nums} | list]
    end)
  end

  def key({string, [_h | _t] = list}) do
    string <> Enum.join(list, ",")
  end
  def key({string, int}) do
    string <> Integer.to_string(int)
  end

  def match(input, n_to_match) do
    # Criteria to match:
    # first n contain only "#" or "?"
    # last is not "#" if length of input is more than n_to_match

    cond do
      String.length(input) == n_to_match ->
        {!String.contains?(input, "."), ""}

      String.length(input) < n_to_match -> {false, ""}

      true ->
        # require IEx; IEx.pry
        {
          !String.contains?(String.slice(input, 0, n_to_match), ".") and
            String.at(input, n_to_match) != "#",
          String.slice(input, n_to_match + 1, String.length(input))
        }
    end
  end

  def count_arrangements({s, []}, memo, n) do
    if String.contains?(s, "#") do
      # IO.inspect("finished with #{n}, #{s} contains #")
      {n, memo}
    else
      # IO.inspect("Ok, did it! finished with #{n + 1}, #{s}")
      {n + 1, memo}
    end
  end

  def count_arrangements({"", [_h | _t]}, memo, n) do
    {n, memo}
  end

  def count_arrangements({string, [to_match | tail] = matches} = params, memo, number_found) do
    memo_key = key(params)
    memoized_value = Map.get(memo, memo_key)

    # if memoized_value do
    #   {memoized_value, memo}
    # else
      Enum.reduce_while(0..(String.length(string) - 1), {number_found, memo}, fn idx, {n, memo} ->
        # IO.inspect("Reduce while on #{string}, index: #{idx}, n: #{n}")

        input = String.slice(string, idx, 1000)

        {nr, mr} = case match(input, to_match) do
          {true, next_string} ->
            # require IEx; IEx.pry
            # IO.inspect("matched #{input} with #{to_match}, #{n}")
            count_arrangements({next_string, tail}, memo, n)
          _ ->
            # require IEx; IEx.pry
            # je ne memoize que là, et pas encore sûr que c'est ok
            {n, Map.put(memo, key({input, matches}), 0)}
        end

        if String.starts_with?(input, "#") do
          # IO.inspect("halt with r #{nr}, input #{input}, to_match #{to_match}")
          {:halt, {nr, mr}}
        else
          # IO.inspect("cont with r #{nr}")
          {:cont, {nr, mr}}
        end
      end)


    # end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> parse_lines()
  end

  def part1(_args \\ []) do
    {n, _memo} = parse()
    |> Enum.reduce({0, %{}}, fn line, {cur_n, cur_memo} ->
      count_arrangements(line, cur_memo, cur_n)

      # {res, Map.put(memo, key(line), res)}

    end)

    # require IEx; IEx.pry
    n
  end

  def part2(_args \\ []) do
  end
end
