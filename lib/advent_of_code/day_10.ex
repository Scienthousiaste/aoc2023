defmodule AdventOfCode.Day10 do
  def input(test? \\ false) do
    if test? do
      # """
      # FS7
      # |.|
      # L-J
      # """

      # """
      # FF7FSF7F7F7F7F7F---7
      # L|LJ||||||||||||F--J
      # FL-7LJLJ||||||LJL-77
      # F--JF--7||LJLJ7F7FJ-
      # L---JF-JLJ.||-FJLJJ7
      # |F|F-JF---7F7-L7L|7|
      # |FFJF7L7F-JF7|JL---7
      # 7-L-JL7||F7|L7F-7F7|
      # L.L7LFJ|||||FJL7||LJ
      # L7JLJL-JLJLJL--JLJ.L
      # """

      # Should find 8, finds 9, it's the one on {4, 4} that is considered inside, but it can squeeze out

      """
      .F----7F7F7F7F-7....
      .|F--7||||||||FJ....
      .||.FJ||||||||L7....
      FJL7L7LJLJ||LJIL-7..
      L--J.L7IIILJS7F-7L7.
      ....F-JIIF7FJ|L7L7L7
      ....L7IF7||L7|IL7L7|
      .J...|FJLJ|FJ|F7|.LJ
      ....FJL-7.||.||||...
      ....L---J.LJ.LJLJ...
      """

      # """
      # FF7FSF7F7F7F7F7F---7
      # L|LJ||||||||||||F--J
      # FL-7LJLJ||||||LJL-77
      # F--JF--7||LJLJ7F7FJ-
      # L---JF-JLJ.||-FJLJJ7
      # |F|F-JF---7F7-L7L|7|
      # |FFJF7L7F-JF7|JL---7
      # 7-L-JL7||F7|L7F-7F7|
      # L.L7LFJ|||||FJL7||LJ
      # L7JLJL-JLJLJL--JLJ.L
      # """

      # can't find the loop here...
      # """
      # ..........
      # .S------7.
      # .|F----7|.
      # .||....||.
      # .||....||.
      # .|L-7F-J|.
      # .|..||..|.
      # .L--JL--J.
      # ..........
      # """
    else
      AdventOfCode.Input.get!(10, 2023)
    end
  end

  def parse do
    lines =
      input()
      |> String.split("\n", trim: true)
      |> Enum.with_index(fn line, index -> {index, line} end)
      |> Map.new()

    %{lines: lines, start: find_start(lines)}
  end

  def find_start(lines) do
    Enum.find_value(lines, nil, fn {index, line} ->
      if String.contains?(line, "S") do
        column =
          Enum.reduce_while(String.codepoints(line), 0, fn char, acc ->
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

  def connection?(_, {-1, _}), do: false
  def connection?(_, {_, -1}), do: false

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
        {{x_start + dx, y_start + dy}, origin(dx, dy)}
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)
    |> List.last()
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

  def memorize_pipes(%{start: {x_start, y_start}} = data) do
    for {dx, dy} <- [{0, 1}, {1, 0}, {0, -1}, {-1, 0}] do
      if connection?(data, {x_start + dx, y_start + dy}) do
        # I probably also need origin or something like that here
        {{x_start + dx, y_start + dy}, origin(dx, dy)}
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)
    |> List.first()
    |> travel_with_memorizing(data, [])
  end

  @spec travel_with_memorizing(
          {{integer(), any()}, any()},
          %{:lines => nil | maybe_improper_list() | map(), optional(any()) => any()},
          any()
        ) :: list()
  def travel_with_memorizing({{x, y}, _origin} = position, %{lines: lines} = data, positions) do
    if String.at(lines[y], x) == "S" do
      Enum.reverse(positions)
    else
      travel_with_memorizing(next_position(position, lines), data, [{x, y} | positions])
    end
  end

  def is_inside_pipes?(lines, pipes_position, x, y) do
    #count | J L left of the point that's NOT part of the loop
    if (x > 0) do
      p = Enum.reduce(0..(x - 1), 0, fn xx, parity ->

        char = String.at(lines[y], xx)
        if {xx, y} in pipes_position and char in ["S", "|", "J", "L"] do
          parity + 1
        else
          parity
        end
      end)
      rem(p, 2) == 1
    else
      false
    end
  end

  @spec part2(any()) :: non_neg_integer()
  def part2(_args \\ []) do
    # 799, too high
    # try with 527
    %{start: start, lines: lines} = parse()

    pipes_positions = [start | memorize_pipes(%{start: start, lines: lines})]

    max_x = lines[0] |> String.length() |> Kernel.-(1)

    coords =
      for x <- 0..max_x, y <- 0..(Enum.count(lines) - 1) do
        {x, y}
      end

    points_inside =
      Enum.reduce(coords, [], fn {x, y}, acc ->
        if !({x, y} in pipes_positions) do
          if is_inside_pipes?(lines, pipes_positions, x, y) do
            [{x, y} | acc]
          else
            acc
          end
        else
          acc
        end
      end)

    # Enum.each(0..(Enum.count(lines) - 1), fn y ->
    #   lines[y]
    #   |> String.codepoints()
    #   |> Enum.with_index()
    #   |> Enum.reduce([], fn {_char, x}, list ->
    #     cond do
    #       {x, y} in points_inside -> ["X" | list]
    #       {x, y} in pipes_positions -> ["." | list]
    #       true -> [" " | list]
    #     end
    #   end)
    #   |> Enum.reverse()
    #   |> List.to_string()
    #   |> IO.inspect()
    # end)

    Enum.count(points_inside)
  end
end
