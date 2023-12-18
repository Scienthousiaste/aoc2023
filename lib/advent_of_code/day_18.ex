defmodule AdventOfCode.Day18 do
  @vertical_drill 1
  @horizontal_drill 2

  def input(test \\ false) do
    if test do
      """
      R 6 (#70c710)
      D 5 (#0dc571)
      L 2 (#5713f0)
      D 2 (#d2c081)
      R 2 (#59c680)
      D 2 (#411b91)
      L 5 (#8ceee2)
      U 2 (#caa173)
      L 1 (#1b58a2)
      U 2 (#caa171)
      R 2 (#7807d2)
      U 3 (#a77fa3)
      L 2 (#015232)
      U 2 (#7a21e3)
      """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_18_input.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1))
    |> Enum.map(fn [dir, length, color] ->
      %{direction: dir, length: String.to_integer(length), color: color}
    end)
  end

  def transform_drill_info(data) do
    {list, _} =
      data
      |> Enum.reduce({[{0, 0}], {0, 0}}, fn %{length: l, direction: d}, {coords_list, {x, y}} ->
        next_coords =
          case d do
            "R" -> {x + l, y}
            "D" -> {x, y + l}
            "L" -> {x - l, y}
            "U" -> {x, y - l}
          end

        {[next_coords | coords_list], next_coords}
      end)

    Enum.reverse(list)
  end

  def normalize(list_coords) do
    xs = Enum.map(list_coords, fn {x, _y} -> x end)
    ys = Enum.map(list_coords, fn {_x, y} -> y end)

    {x_min, x_max, y_min, y_max} = {Enum.min(xs), Enum.max(xs), Enum.min(ys), Enum.max(ys)}

    norm =
      list_coords
      |> Enum.map(fn {x, y} ->
        {x - x_min, y - y_min}
      end)

    {norm, {x_max - x_min, y_max - y_min}}
  end

  def count_parity(map, x, y) do
    Enum.count(0..x, fn xx ->
      Map.get(map, {xx, y}) == @vertical_drill
    end)
  end

  def count_inside_or_border(map, max_x, max_y) do
    c =
      for x <- 0..max_x, y <- 0..max_y do
        {x, y}
      end

    Enum.reduce(c, 0, fn {x, y}, count ->
      res = cond do
        Map.get(map, {x, y}) in [@vertical_drill, @horizontal_drill] -> count + 1
        rem(count_parity(map, x, y), 2) == 1 -> count + 1
        true -> count
      end

      if (y == 3 and x == 0) do
        IO.inspect("#{x}, #{y}")
      end
      res
    end)
  end

  def part1(_args \\ []) do
    {drill_coords, {max_x, max_y}} =
      parse()
      |> transform_drill_info()
      |> normalize()

    map_array =
      for x <- 0..max_x, y <- 0..max_y do
        {{x, y}, 0}
      end
      |> Map.new()

    {horizontally_drilled_map, _} =
      Enum.reduce(drill_coords, {map_array, {nil, nil}}, fn {x, y}, {field, {prev_x, prev_y}} ->
        if prev_x == nil do
          {field, {x, y}}
        else
            cc = for xx <- prev_x..x, yy <- prev_y..y do
              {xx, yy} # correct
            end
            res = cc
            |> Enum.reduce(field, fn {xxx, yyy}, f ->
              Map.put(f, {xxx, yyy}, @horizontal_drill)
            end)

          {res, {x, y}}
        end
      end)

    {drilled_map, _} =
      Enum.reduce(drill_coords, {horizontally_drilled_map, {nil, nil}}, fn {x, y}, {field, {prev_x, prev_y}} ->

        # AAHHHH CEST PEUT ETRE PAS y != prev_y, initialement c'était U ET D!!
        if prev_x == nil or (y == prev_y) do
          {field, {x, y}}
        else

          # require IEx; IEx.pry
          top_y = Enum.max([prev_y, y])
          bottom_y = Enum.min([prev_y, y])

          res =
            Enum.reduce((bottom_y + 1)..top_y, field, fn yy, f ->
              # A TOUS LES COUPS LE PROBLEME C'EST LES EDGE QUI SE FONT ECRASER
              # Les coins du haut verticaux devraient TOUJOURS être comptés, et les coins du bas JAMAIS
              Map.put(f, {x, yy}, @vertical_drill)
            end)

          {res, {x, y}}
        end
      end)

    # it was 39194
    drilled_map
    |> count_inside_or_border(max_x, max_y)
  end

  # def flood_fill(map, {x, y}, max_x, max_y) do
  #   end_map = Enum.reduce_while(0..100000, {map, [{x, y}]}, fn _x, {mp, [{x, y} | rest]} ->
  #     {next_m, next_l} = if (Map.get(mp, {x, y}) == false) do
  #       {
  #         Map.put(mp, {x, y}, true),
  #         [{(x + 1), y}, {(x - 1), y}, {x, (y + 1)}, {x, (y - 1)}] ++ rest
  #       }
  #     else
  #       {
  #         mp,
  #         rest
  #       }
  #     end

  #     if next_l == [] do
  #       {:halt, next_m}
  #     else
  #       {:cont, {next_m, next_l}}
  #     end
  #   end)

  #   end_map

  # end

  def part2(_args \\ []) do
  end
end
