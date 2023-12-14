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

  def move_boolder_north(field, x, y) do
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

  def move_boolder_south(field, x, y, height) do
    new_y = Enum.reduce_while((y + 1)..(height - 1), y, fn new_y, prev_y ->
      cond do
        new_y == height -> {:halt, height - 1}
        c_at(field, x, new_y) in ["#", "O"] -> {:halt, prev_y}
        c_at(field, x, new_y) == "." -> {:cont, new_y}
      end
    end)

    field
    |> put_at(x, y, ".")
    |> put_at(x, new_y, "O")
  end

  def move_boolder_east(field, x, y, width) do
    new_x = Enum.reduce_while((x + 1)..(width - 1), x, fn new_x, prev_x ->
      cond do
        new_x == width -> {:halt, width - 1}
        c_at(field, new_x, y) in ["#", "O"] -> {:halt, prev_x}
        c_at(field, new_x, y) == "." -> {:cont, new_x}
      end
    end)

    field
    |> put_at(x, y, ".")
    |> put_at(new_x, y, "O")
  end

  def move_boolder_west(field, x, y) do
    new_x = Enum.reduce_while((x-1)..0, x, fn new_x, prev_x ->
      cond do
        new_x == -1 -> {:halt, 0}
        c_at(field, new_x, y) in ["#", "O"] -> {:halt, prev_x}
        c_at(field, new_x, y) == "." -> {:cont, new_x}
      end
    end)

    field
    |> put_at(x, y, ".")
    |> put_at(new_x, y, "O")
  end

  def dimensions(array) do
    {Enum.count(array[0]), Enum.count(array)}
  end

  def move(array, :north) do
    {width, height} = dimensions(array)

    coords = for x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}

    Enum.reduce(coords, array, fn {x, y}, field ->
      if c_at(field, x, y) == "O" do
        move_boolder_north(field, x, y)
      else
        field
      end
    end)
  end

  def move(array, :south) do
    {width, height} = dimensions(array)

    coords = for x <- 0..(width - 1), y <- (height - 1)..0, do: {x, y}

    Enum.reduce(coords, array, fn {x, y}, field ->
      if c_at(field, x, y) == "O" do
        move_boolder_south(field, x, y, height)
      else
        field
      end
    end)
  end

  def move(array, :east) do
    {width, height} = dimensions(array)

    coords = for y <- 0..(height - 1), x <- (width - 1)..0, do: {x, y}

    Enum.reduce(coords, array, fn {x, y}, field ->
      if c_at(field, x, y) == "O" do
        move_boolder_east(field, x, y, width)
      else
        field
      end
    end)
  end

  def move(array, :west) do
    {width, height} = dimensions(array)

    coords = for y <- 0..(height - 1), x <- 0..(width - 1), do: {x, y}

    Enum.reduce(coords, array, fn {x, y}, field ->
      if c_at(field, x, y) == "O" do
        move_boolder_west(field, x, y)
      else
        field
      end
    end)
  end

  def compute_load(array) do
    {width, height} = dimensions(array)

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
    initial = parse()

    {res_after_cycle, _seen_states} = Enum.reduce_while(1..1_000_000_000, {initial, []}, fn cycle_number, {array, seen_states} ->
      res_after_cycle = array
      |> move(:north)
      |> move(:west)
      |> move(:south)
      |> move(:east)

      if (res_after_cycle in seen_states) do
        # {:halt, {cycle_number, seen_states}}
        IO.inspect("cycle_number #{cycle_number}, load #{compute_load(res_after_cycle)}")
        if (cycle_number > 500) do
          require IEx; IEx.pry
        end
        {:cont, {res_after_cycle, seen_states}}
      else
        {:cont, {res_after_cycle, [res_after_cycle | seen_states]}}
      end
    end)

    compute_load(res_after_cycle)
  end
end
