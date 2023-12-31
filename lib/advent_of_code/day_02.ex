defmodule AdventOfCode.Day02 do

  @max_cubes %{"red" => 12, "green" => 13, "blue" => 14}
  @line_regex ~r/Game (?<game_id>\d*): (?<data>.*)/
  @grb_regex ~r/(?<n>\d*) (?<color>.*)/

  def parse_data(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"game_id" => game_id, "data" => data} = Regex.named_captures(@line_regex, line)
      res = String.split(data, ";", trim: true)
      |> Enum.map(fn game_data ->
        String.split(game_data, ",")
        |> Enum.map(&String.trim(&1))
        |> Enum.reduce(%{}, fn color_data, acc ->
          %{"n" => n, "color" => color} = Regex.named_captures(@grb_regex, color_data)
          Map.put(acc, color, String.to_integer(n))
        end)
      end)

      {String.to_integer(game_id), res}
    end)
  end

  def part1(_args) do
    AdventOfCode.Input.get!(2, 2023)
    |> parse_data()
    |> Enum.map(fn {id, games} ->
      {id, Enum.any?(games, fn map ->
        Enum.any?(@max_cubes, fn {color, max_val} ->
          col_val = Map.get(map, color)
          (not is_nil(col_val)) and (col_val > max_val)
        end)
      end)}
    end)
    |> Enum.reduce(0, fn {id, game_impossible}, acc ->
      if game_impossible do
        acc
      else
        acc + id
      end
    end)
  end

  def part2(_args) do
    # what is the fewest number of cubes of each color that could have been in the bag to make the game possible?

    # input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\nGame 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\nGame 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\nGame 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\nGame 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green\n"

    AdventOfCode.Input.get!(2, 2023)
    |> parse_data()
    |> Enum.map(fn {_id, games} ->
      ["blue", "green", "red"]
      |> Enum.map(fn color ->
        Enum.map(games, fn game ->
          col_n = Map.get(game, color)
          if is_nil(col_n), do: 0, else: col_n
        end)
        |> Enum.max()
      end)
      |> Enum.reduce(1, fn n, acc -> acc * n end)
    end)
    |> Enum.sum()
  end
end
