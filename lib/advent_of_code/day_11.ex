defmodule AdventOfCode.Day11 do

  def input(test? \\ false) do
    if test? do
      # """
      # ...
      # .#.
      # ...
      # """
      """
      ...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#.....
      """
    else
      AdventOfCode.Input.get!(11, 2023)
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints(&1))
  end

  def add_column(lines, x) do
    Enum.map(lines, fn line ->
      List.insert_at(line, x, ".")
    end)
  end

  def expand_universe(lines) do
    max_x = lines
    |> List.first
    |> Enum.count
    |> Kernel.-(1)

    {expanded_columns_universe, _} = Enum.reduce(0..max_x, {lines, 0}, fn x, {cur_lines, added_cols} ->
      if Enum.all?(cur_lines, fn line -> Enum.at(line, x + added_cols) == "." end) do
        {add_column(cur_lines, x + added_cols), added_cols + 1}
      else
        {cur_lines, added_cols}
      end
    end)

    Enum.reduce(expanded_columns_universe, [], fn line, cur_lines ->
      if Enum.all?(line, fn c -> c == "." end) do
        [line | [line | cur_lines]]
      else
        [line | cur_lines]
      end
    end)
    |> Enum.reverse
  end

  def find_galaxies(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, index_y}, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, index_x}, acc2 ->
        if char == "#" do
          [{index_x, index_y} | acc2]
        else
          acc2
        end
      end)
    end)
  end

  def distance_between({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def part1(_args \\ []) do
    galaxies = parse()
    |> expand_universe
    |> find_galaxies

    n_galaxies = Enum.count(galaxies)
    Enum.reduce(Enum.with_index(galaxies), 0, fn {galaxy, idx}, sum_distances ->

      if (idx + 1< n_galaxies) do
        Enum.reduce((idx+1)..(n_galaxies - 1), sum_distances, fn n, cur_sum ->
          if (Enum.at(galaxies, n) == nil) do
            require IEx; IEx.pry
          end
          cur_sum + distance_between(galaxy, Enum.at(galaxies, n))
        end)
      else
        sum_distances
      end
    end)
  end

  def part2(_args \\ []) do
  end
end
