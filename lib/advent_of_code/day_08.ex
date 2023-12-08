defmodule AdventOfCode.Day08 do
  @regex_line ~r/(?<start_pos>[A-Z]{3}) = \((?<left>[A-Z]{3})\, (?<right>[A-Z]{3})\)/
  def input(test? \\ false) do
    if test? do
      """
      LLR

      AAA = (BBB, BBB)
      BBB = (AAA, ZZZ)
      ZZZ = (ZZZ, ZZZ)
      """
    else
      AdventOfCode.Input.get!(8, 2023)
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.reduce(%{moves: %{}}, fn {line, idx}, data ->
      case idx do
        0 -> Map.put(data, :lr, line)
        _ -> add_line(data, line)
      end
    end)
  end

  def add_line(data, nil) do
    require IEx; IEx.pry
    data
  end

  def add_line(data, line) do
    %{"start_pos" => s, "left" => left, "right" => right} =
    Regex.named_captures(@regex_line, line)

    Map.update(data, :moves, nil, fn existing -> Map.put(existing, s, [left, right]) end)
  end

  def part1(_args \\ []) do
    iter(parse(), 0, 0, "AAA")
  end

  def iter(_, _index_move, nb_moves, "ZZZ"), do: nb_moves

  def iter(%{lr: lr, moves: moves} = data, index_move, nb_moves, position) do
    move = Map.get(moves, position)
    case String.at(lr, index_move) do
      "L" -> iter(data, rem(index_move + 1, String.length(lr)), nb_moves + 1, Enum.at(move, 0))
      "R" -> iter(data, rem(index_move + 1, String.length(lr)), nb_moves + 1, Enum.at(move, 1))
    end
  end

  def part2(_args \\ []) do
  end
end
