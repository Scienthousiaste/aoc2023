defmodule AdventOfCode.Day10 do

  def input(test? \\ false) do
    if test? do
      """
      7-F7-
      .FJ|7
      SJLL7
      |F--J
      LJ.LJ
      """
    else
      AdventOfCode.Input.get!(10, 2023)
    end
  end

  def parse do
    lines = input()
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn line, index -> {index, line} end)
    |> Map.new

    %{lines: lines, start: find_start(lines)}
  end

  def find_start(lines) do
    Enum.find_value(lines, nil, fn {index, line} ->
      if String.contains?(line, "S") do
        column = Enum.reduce_while(String.codepoints(line), 0, fn char, acc ->
          if char == "S" do
            {:halt, acc}
          else
            {:cont, acc + 1}
          end
        end)
        {column, index}
      end
    end)
  end

  def connection?(data, {p2_x, p2_y}) do
    {p1_x, p1_y} = data.start

    p2_char = String.at(data.lines[p2_y], p2_x)

    cond do
      p1_y - 1 == p2_y -> p2_char in ["F", "|", "7"]
      p1_y + 1 == p2_y -> p2_char in ["J", "|", "L"]
      p1_x + 1 == p2_x -> p2_char in ["-", "J", "7"]
      p1_x - 1 == p2_x -> p2_char in ["-", "F", "L"]
    end
  end


  # | is a vertical pipe connecting north and south.
  # - is a horizontal pipe connecting east and west.
  # L is a 90-degree bend connecting north and east.
  # J is a 90-degree bend connecting north and west.
  # 7 is a 90-degree bend connecting south and west.
  # F is a 90-degree bend connecting south and east.

  def next_direction("|", :south), do: :south
  def next_direction("|", :north), do: :north

  def next_direction("-", :east), do: :east
  def next_direction("-", :west), do: :west

  def next_direction("L", :north), do: :east
  def next_direction("L", :east), do: :north

  def next_direction("J", :north), do: :west
  def next_direction("J", :west), do: :north

  def next_direction("7", :south), do: :west
  def next_direction("7", :west), do: :south

  def next_direction("F", :south), do: :east
  def next_direction("F", :east), do: :south

# # mmmmh
  def next_direction("L", :south), do: :east
  def next_direction("L", :west), do: :north

  def next_direction("J", :south), do: :west
  def next_direction("J", :east), do: :north

  def next_direction("7", :north), do: :west
  def next_direction("7", :east), do: :south

  def next_direction("F", :north), do: :east
  def next_direction("F", :west), do: :south


  def origin(1, 0), do: :west
  def origin(-1, 0), do: :east
  def origin(0, 1), do: :north
  def origin(0, -1), do: :south

  def next_y(y, :south), do: y + 1
  def next_y(y, :north), do: y - 1
  def next_y(y, _), do: y
  def next_x(x, :east), do: x + 1
  def next_x(x, :west), do: x - 1
  def next_x(x, _), do: x

  def travel(%{start: {x_start, y_start}} = data) do
    for {dx, dy} <- [{0, 1}, {1, 0}, {0, -1}, {-1, 0}] do
      if connection?(data, {x_start + dx, y_start + dy}) do
        {{x_start + dx, y_start + dy}, origin(dx, dy)} # I probably also need origin or something like that here
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)
    |> List.first
    |> do_travel(data, 0)
  end

  def is_same?({x1, y1}, {x2, y2}) do
    x1 === x2 and y1 === y2
  end

  def next_position({{x, y}, origin}, lines) do
    char = String.at(lines[y], x)
    dir = next_direction(char, origin)
    {{next_x(x, dir), next_y(y, dir)}, dir}
  end

  def do_travel({{x, y}, _origin} = position, %{lines: lines} = data, length) do
    if String.at(lines[y], x) == "S" do
      (length + 1) / 2
    else
      do_travel(next_position(position, lines), data, length + 1)
    end
  end

  def part1(_args \\ []) do
    parse()
    |> travel()
  end

  def part2(_args \\ []) do
  end
end
