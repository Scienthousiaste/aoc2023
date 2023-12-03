defmodule AdventOfCode.Day03 do

  @spec parse_data() :: %{cols: non_neg_integer(), input: [binary()], lines: non_neg_integer()}
  def parse_data() do
    input = AdventOfCode.Input.get!(3, 2023)
    |> String.split("\n", trim: true)

    # input = """
    # 467..114..
    # ...*......
    # ..35..633.
    # ......#...
    # 617*......
    # .....+.58.
    # ..592.....
    # ......755.
    # ...$.*....
    # .664.598..
    # """
    # |> String.split("\n", trim: true)

    lines = Enum.count(input)
    cols = String.length(List.first(input))

    all_numbers = input
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, line_idx}, acc ->
      {res, _, _, _} = line
      |> String.codepoints()
      |> Enum.reduce({[], false, 0, nil}, fn char, {nums, is_in_num, index, start_index} ->
        cond do
          is_digit?(char) and not is_in_num -> {nums, true, index + 1, index}
          is_digit?(char) and is_in_num ->
            if index == cols - 1 do
              {add_num(nums, line, start_index, index + 1), false, index + 1, nil}
            else
              {nums, true, index + 1, start_index}
            end
          not is_digit?(char) and is_in_num -> {add_num(nums, line, start_index, index), false, index + 1, nil}
          not is_digit?(char) and not is_in_num -> {nums, false, index + 1, nil}
        end
      end)
      acc ++ Enum.map(res, fn m -> Map.put(m, :y, line_idx) end)
    end)

    %{input: input, all_numbers: all_numbers, lines: lines, cols: cols}
  end

  def part1(_args \\ []) do
    %{
      all_numbers: all_numbers,
      input: input,
      lines: lines,
      cols: cols
    } = parse_data()

    all_numbers
    |> Enum.filter(fn n -> find_surrounding_symbol(n, input, lines, cols) end)
    |> Enum.map(&(&1.num))
    |> Enum.sum()
  end

  def find_surrounding_symbol(n_data, input, lines, cols) do
    start_x = Enum.max([n_data.x_begin - 1, 0])
    end_x = Enum.min([n_data.x_end + 1, cols - 1])
    start_y = Enum.max([n_data.y - 1, 0])
    end_y = Enum.min([n_data.y + 1, lines - 1])

    coords_to_check = for x <- start_x..end_x, y <- start_y..end_y do
      {x, y}
    end

    Enum.any?(coords_to_check, fn {x, y} ->
      Enum.at(input, y)
      |> String.at(x)
      |> is_symbol?()
    end)
  end

  def add_num(nums, line, start_index, last_index) do
    new_number = line
    |> String.slice(start_index, last_index - start_index)
    |> String.to_integer

    nums ++ [%{num: new_number, x_begin: start_index, x_end: last_index - 1}]
  end

  def is_digit?(char), do: char >= "0" && char <= "9"
  def is_symbol?(char), do: not is_digit?(char) and char != "."

  def part2(_args \\ []) do
    %{
      all_numbers: all_numbers,
      input: input,
      lines: lines,
      cols: cols
    } = parse_data()


    all_gears = input
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, index_line}, gears ->
      res = line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {char, index_char} ->
        char == "*"
      end)
      |> Enum.map(fn {"*", x} ->
        {x, index_line}
      end)
      gears ++ res
    end)

    replace_gears_with_adjacent_numbers(all_gears, all_numbers)
    |> Enum.filter(&(Enum.count(&1) == 2))
    |> Enum.map(fn [n1, n2] -> n1 * n2 end)
    |> Enum.sum()
  end

  def replace_gears_with_adjacent_numbers(gears, numbers) do
    gears
    |> Enum.map(fn {gear_x, gear_y} ->

      Enum.filter(numbers, fn n ->
        abs(gear_y - n.y) <= 1 and (gear_x >= (n.x_begin - 1) and gear_x <= (n.x_end + 1))
      end)
      |> Enum.map(&(&1.num))
    end)
  end
end
