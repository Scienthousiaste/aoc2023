defmodule AdventOfCode.Day08 do
  @regex_line ~r/(?<start_pos>.{3}) = \((?<left>.{3})\, (?<right>.{3})\)/
  def input(test? \\ false) do
    if test? do
      """
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
      """
    else
      AdventOfCode.Input.get!(8, 2023)
    end
  end

  def parse(add_line) do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{moves: %{}, current_positions: []}, fn {line, idx}, data ->
      case idx do
        0 -> Map.put(data, :lr, line)
        _ -> add_line.(data, line)
      end
    end)
  end

  def add_line1(data, line) do
    %{"start_pos" => s, "left" => left, "right" => right} =
      Regex.named_captures(@regex_line, line)

    Map.update(data, :moves, nil, fn existing -> Map.put(existing, s, [left, right]) end)
  end

  def add_line2(data, line) do
    %{"start_pos" => s, "left" => left, "right" => right} =
      Regex.named_captures(@regex_line, line)

    data2 =
      data
      |> Map.update(:moves, nil, fn existing -> Map.put(existing, s, [left, right]) end)

    if String.ends_with?(s, "A") do
      Map.update(data2, :current_positions, [], fn existing -> [s | existing] end)
    else
      data2
    end
  end

  def part1(_args \\ []) do
    iter(parse(&add_line1/2), 0, 0, "AAA")
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
    # iter2(parse(&add_line2/2), 0, 0)
    solve(parse(&add_line2/2))
  end

  def next_positions(%{moves: moves, current_positions: cur}, "L") do
    Enum.map(cur, fn position ->
      [left, _] = Map.get(moves, position)
      left
    end)
  end
  def next_positions(%{moves: moves, current_positions: cur}, "R") do
    Enum.map(cur, fn position ->
      [_, right] = Map.get(moves, position)
      right
    end)
  end

  def iter2(%{lr: lr, current_positions: cur} = data, index_move, nb_moves) do
    #Brute force
    if Enum.all?(cur, fn s -> String.ends_with?(s, "Z") end) do
      nb_moves
    else
      iter2(
        Map.put(data, :current_positions, next_positions(data, String.at(lr, index_move))),
        rem(index_move + 1, String.length(lr)),
        nb_moves + 1
      )
    end
  end

  def get_next_position(position, map_moves, "L"), do: Enum.at(Map.get(map_moves, position), 0)
  def get_next_position(position, map_moves, "R"), do: Enum.at(Map.get(map_moves, position), 1)

  def find_loop(start, lr, map_moves) do
    res = do_find_loop(start, lr, 0, map_moves, 0)

    # AdventOfCode.Day08.position_after_n_iter(start, map_moves, lr, 0, )
    #  AdventOfCode.Day08.position_after_n_iter(start, map_moves, lr, 0, 19099) ça c'est bon, ça fini par Z
    # require IEx; IEx.pry

    res
  end

  def do_find_loop(position, lr, index_move, map_moves, distance_to_loop) do
    next_pos = get_next_position(position, map_moves, String.at(lr, index_move))

    if String.ends_with?(position, "Z") do
      explore_loop(next_pos, lr, rem(index_move + 1, String.length(lr)), map_moves, distance_to_loop, 0, position, index_move)
    else
      do_find_loop(next_pos, lr, rem(index_move + 1, String.length(lr)), map_moves, distance_to_loop + 1)
    end
  end

  def explore_loop(position, _lr, index_move, _map_moves, distance_to_loop, length_loop, start_loop, start_index_move) when (position == start_loop and index_move == start_index_move and length_loop != 0) do
    {distance_to_loop, length_loop}
  end

  def explore_loop(position, lr, index_move, map_moves, distance_to_loop, length_loop, start_loop, start_index_move) do
    next_pos = get_next_position(position, map_moves, String.at(lr, index_move))

    explore_loop(next_pos, lr, rem(index_move + 1, String.length(lr)), map_moves, distance_to_loop, length_loop + 1, start_loop, start_index_move)
  end


  def solve(%{lr: lr, moves: moves, current_positions: cur}) do
    # for each position, find the loop it does
    loops = Enum.map(cur, &find_loop(&1, lr, moves))
    require IEx; IEx.pry
    loops
    |> generate_nums_till_same()
  end


  def generate_nums_till_same(loops) do
    # 24400198871 "too low"
    loops_with_mins = loops
    |> Enum.map(fn {n, _nn} ->
      %{loop: n, min: n}
    end)

    generate_next_num(loops_with_mins, 1)
  end

  def generate_next_num(loops, iter_number) do
    mins = Enum.map(loops, &(&1.min))
    min0 = List.first(mins)

    #probably a way to multiply all, then to use gcd(integer1, integer2) ?
    # that's brute force too... answer is 16 187 743 689 077
    # should compute common multiplier of loop sizes (19099 21251 14257 12643 19637 15871)
    if Enum.all?(mins, fn x -> x == min0 end) do
      min0
    else

      [first | rest] = loops |> Enum.sort_by(& &1.min)
      updated_loops = [Map.update(first, :min, 0, fn x -> x + first.loop end) | rest]

      generate_next_num(updated_loops, iter_number + 1)
    end
  end

  #AdventOfCode.Day08.parse(&AdventOfCode.Day08.add_line2/2)
  def position_after_n_iter(position, _map_moves, _lr, _index_move, 0), do: position
  def position_after_n_iter(position, map_moves, lr, index_move, n) do
    next_pos = get_next_position(position, map_moves, String.at(lr, index_move))
    position_after_n_iter(next_pos, map_moves, lr, rem(index_move + 1, String.length(lr)), n - 1)
  end
end
