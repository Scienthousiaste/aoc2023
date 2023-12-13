defmodule AdventOfCode.Day12 do
  def input(test \\ false) do
    if test do
      """
      ?##..?#?#?? 2,4

      """

      #  Résultats corrects:
      # ???.### 1,1,3
      # ?? 1

      # """
      # #.??..??...?##. 1,1,3
      # # ??????#??#?? 1,1,5,1
      # # ?#?#??##?#? 2,5,1
      # # ????????.?#???#??##? 2,1,2,1,1,6
      # # #???#?????.?#?. 2,1,2,1
      # # ?##..?#?#?? 2,4
      # """
    else
      AdventOfCode.Input.get!(12, 2023)
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
      {n, memo}
    else
      require IEx; IEx.pry
      {n + 1, memo}
    end
  end

  def count_arrangements({"", [_h | _t]}, memo, n) do
    {n, memo}
  end

  def count_arrangements({string, [to_match | tail]} = params, memo, number_found) do
    memo_key = key(params)
    memoized_value = Map.get(memo, memo_key)

    if memoized_value do
      {memoized_value, memo}
    else
      Enum.reduce(0..(String.length(string) - 1), {number_found, memo}, fn idx, {n, memo} ->
        input = String.slice(string, idx, 1000)

        # Il faut s'arrêter quand on a un #... c'est le moment ou jamais de match, here and now

        case match(input, to_match) do
          {true, next_string} ->
            # require IEx; IEx.pry
            res = count_arrangements({next_string, tail}, memo, n)
            require IEx; IEx.pry
            res
            # {nn, Map.put(memmo, key({next_string, tail}), nn)}
          _ ->
            # require IEx; IEx.pry
            {n, Map.put(memo, key({input, to_match}), 0)}
        end
      end)


    end
  end

  def parse() do
    input(true)
    |> String.split("\n", trim: true)
    |> parse_lines()
  end

  def part1(_args \\ []) do
    {n, _memo} = parse()
    |> Enum.reduce({0, %{}}, fn line, {cur_n, cur_memo} ->
      count_arrangements(line, cur_memo, cur_n)
      # {res, Map.put(memo, key(line), res)}
    end)

    require IEx; IEx.pry
    n
  end

  def part2(_args \\ []) do
  end
end
