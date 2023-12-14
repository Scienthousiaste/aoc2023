defmodule AdventOfCode.Day13 do
  def input(test \\ false) do
    if test do
      """
      #.##.#..#...#..
      .#...#.....#...
      #.#..#.#.##.###
      .#####.#.#..#.#
      .#####.#.#..#.#
      #.#..#.#.##.###
      .#...#.#...#...
      #.##.#..#...#..
      #.#.#.###.####.
      #..###....###..
      #..###....###..
      """

      # """
      # #...##..#
      # #....#..#
      # ..##..###
      # #####.##.
      # #####.##.
      # ..##..###
      # #....#..#

      # #.##..##.
      # ..#.##.#.
      # ##......#
      # ##......#
      # ..#.##.#.
      # ..##..##.
      # #.#.##.#.
      # """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_13_input.txt")
      contents
    end
  end

  def find_vertical_symmetry(rows) do
    nb_cols = rows
    |> List.first
    |> String.length

    cols = Enum.map(1..nb_cols, fn idx ->
      col_data = Enum.map(rows, fn row ->
        String.at(row, idx - 1)
      end)
      |> Enum.join
      {idx, col_data}
    end)
    |> Map.new

    res_vert = Enum.find(2..nb_cols, fn vertical_index ->
      Enum.all?((1..vertical_index), fn x ->
        if is_nil(cols[vertical_index - x]) || is_nil(cols[vertical_index + x - 1]) do
          true
        else
          cols[vertical_index - x] == cols[vertical_index + x - 1]
        end
      end)
    end)

    if (res_vert) do
      res_vert - 1
    else
      # require IEx; IEx.pry
      IO.inspect("fail")
      0
    end
  end

  def find_symmetry(rows) do
    map_rows = rows
    |> Enum.with_index(fn e, idx -> {idx + 1, e} end)
    |> Map.new

    nb_rows = Enum.count(map_rows)

    res_horiz = Enum.find(2..nb_rows, fn horizontal_index ->
      Enum.all?((1..horizontal_index), fn x ->
        if is_nil(map_rows[horizontal_index - x]) || is_nil(map_rows[horizontal_index + x - 1]) do
          true
        else
          # res = map_rows[horizontal_index - x] == map_rows[horizontal_index + x - 1]
          # IO.inspect("#{horizontal_index - x}, #{horizontal_index + x - 1}, #{res}")
          map_rows[horizontal_index - x] == map_rows[horizontal_index + x - 1]
        end
      end)
    end)

    if res_horiz do
      100 * (res_horiz - 1)
    else
      find_vertical_symmetry(rows)
    end
  end

  def parse() do
    input()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&(String.split(&1, "\n", trim: true)))
  end

  def part1(_args \\ []) do
    parse()
    |> Enum.map(&find_symmetry/1)
    |> Enum.sum
  end

  def part2(_args) do
  end
end
