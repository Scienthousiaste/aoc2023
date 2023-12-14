defmodule AdventOfCode.Day14 do
  def input(test \\ false) do
    if (test) do
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_14_input.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints(&1))
    |> Enum.with_index(fn x, idx -> {idx, x} end)
    |> Map.new
  end

  def c_at(field, x, y) do
    field[y]
    |> Enum.at(x)
  end

  def put_at(field, x, y, char) do
    Map.update(field, y, [], fn string ->
      List.update_at(string, x, fn _c -> char end)
    end)
  end

  def move_boolder_up(field, x, y) do
    new_y = Enum.reduce_while((y-1)..0, y, fn new_y, prev_y ->
      cond do
        new_y == -1 -> {:halt, 0}
        c_at(field, x, new_y) in ["#", "O"] -> {:halt, prev_y}
        c_at(field, x, new_y) == "." -> {:cont, new_y}
      end
    end)

    field
    |> put_at(x, y, ".")
    |> put_at(x, new_y, "O")
  end

  def move(array, :north) do

    width = array[0] |> Enum.count
    height = Enum.count(array)

    # if other direction than north, we want to change: the order of coords (for south)
    coords = for x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}

    Enum.reduce(coords, array, fn {x, y}, field ->
      if c_at(field, x, y) == "O" do
        move_boolder_up(field, x, y)
      else
        field
      end
    end)
  end

  def compute_load(array) do
    width = array[0] |> Enum.count
    height = Enum.count(array)

    coords = for x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}
    Enum.reduce(coords, 0, fn {x, y}, sum ->
      if c_at(array, x, y) == "O" do
        sum + (height - y)
      else
        sum
      end
    end)
  end

  def part1(_args \\ []) do
    parse()
    |> move(:north)
    |> compute_load()
  end

  def part2(_args \\ []) do
  end
end
