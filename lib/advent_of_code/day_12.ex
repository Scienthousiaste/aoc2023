defmodule AdventOfCode.Day12 do
  def input(test \\ false) do
    if test do
      """
      ???.### 1,1,3
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
      contents
    end
  end

  def parse_lines(lines) do
    Enum.reduce(lines, [], fn line, list ->
      [l, r] = String.split(line)
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
        {
          !String.contains?(String.slice(input, 0, n_to_match), ".") and
            String.at(input, n_to_match) != "#",
          String.slice(input, n_to_match + 1, String.length(input))
        }
    end
  end

  def count_arrangements({s, []}, memo, n) do
    if String.contains?(s, "#") do
      {n, memo}
    else
      {n + 1, memo}
    end
  end

  def count_arrangements({"", [_h | _t]}, memo, n) do
    {n, memo}
  end

  def count_arrangements({string, [to_match | tail]} = params, memo, init_number) do
    memo_key = key(params)
    memoized_value = Map.get(memo, memo_key)

    if memoized_value do
      {init_number + memoized_value, memo}
    else
      {final_n, final_memo} = Enum.reduce_while(0..(String.length(string) - 1), {init_number, memo}, fn idx, {n, memo} ->

        input = String.slice(string, idx, 1000)

        {res_number, res_memo} = case match(input, to_match) do
          {true, next_string} ->
            count_arrangements({next_string, tail}, memo, n)
          _ ->
            {n, memo}

            # {n, Map.put(memo, key({input, to_match}), 0)}
        end

        if String.starts_with?(input, "#") do
          # put in memo res_number - n ? res_numbe r - number_found ?
          {:halt, {res_number, res_memo}}
        else
          {:cont, {res_number, res_memo}}
        end
      end)

      # require IEx; IEx.pry
      {final_n, Map.put(final_memo, memo_key, (final_n - init_number) )}
    end
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
    end)
    n
  end

  def unfold({l, r}) do
    {Enum.join([l, l, l, l, l], "?"), r ++ r ++ r ++ r ++ r}
  end

  def part2(_args \\ []) do
    {n, _memo} = parse()
    |> Enum.map(fn line -> unfold(line) end)
    |> Enum.reduce({0, %{}}, fn line, {cur_n, cur_memo} ->
      count_arrangements(line, cur_memo, cur_n)
    end)
    n
  end
end
