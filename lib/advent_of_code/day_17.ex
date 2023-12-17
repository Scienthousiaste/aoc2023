defmodule AdventOfCode.Day17 do
  import Heap

  def input(test \\ false) do
    if test do
      """
      2413432311323
      3215453535623
      3255245654254
      3446585845452
      4546657867536
      1438598798454
      4457876987766
      3637877979653
      4654967986887
      4564679986453
      1224686865563
      2546548887735
      4322674655533
      """

      # """
      # 1888
      # 1888
      # 1888
      # 1888
      # 1888
      # """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_17_input.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn e, idx -> {idx, e} end)
    |> Enum.map(fn {i, e} ->
      {i, e |> String.split("", trim: true) |> Enum.map(&String.to_integer(&1))}
    end)
    |> Map.new()
  end

  def reconstruct_path(%{came_from: came_from, input: input, goal: goal}, current) do

    {_p, s} = Enum.reduce_while(1..10000, {[], current, 0}, fn _x, {path, cur, sum_weight} ->

      case Map.get(came_from, cur) do
        nil ->
        {:halt, {path, sum_weight}}
        prev ->
          [x, y, _] = String.split(prev, ",")
          weight = weight_at({String.to_integer(x), String.to_integer(y)}, input)
          {:cont, {[prev | path], prev, sum_weight + weight}}
      end
    end)
    s + weight_at(goal, input) - weight_at({0, 0}, input)
  end

  def extract_min_weight(open_set, data) do
    current = Heap.root(open_set)

    {current, Heap.pop(open_set),
     %{data | in_open_set: Map.delete(data.in_open_set, current.key)}}
  end

  def a_star(open_set, data) do
    if Heap.empty?(open_set) == 0 do
      require IEx
      IEx.pry()
    end

    {current, open_set, data} = extract_min_weight(open_set, data)
    if current.position == data.goal do
      reconstruct_path(data, current.key)
    else
      {next_open_set, next_data} = add_neighbours(open_set, current, data)
      a_star(next_open_set, next_data)
    end
  end

  def opposite(:u), do: :d
  def opposite(:d), do: :u
  def opposite(:r), do: :l
  def opposite(:l), do: :r

  def direction_possible?(current, dir, data) do
    prev = current.prev_directions
    opposite_dir = opposite(dir)
    {x, y} = current.position

    cond do
      match?({^dir, ^dir, ^dir}, prev) -> false
      match?({^opposite_dir, _, _}, prev) -> false
      dir == :u and y - 1 < 0 -> false
      dir == :d and y + 1 >= data.height -> false
      dir == :l and x - 1 < 0 -> false
      dir == :r and x + 1 >= data.width -> false
      true -> true
    end
  end

  def h({x_pos, y_pos}, {x_goal, y_goal}) do
    x_goal - x_pos + (y_goal - y_pos)
  end

  def move({x, y}, :u), do: {x, y - 1}
  def move({x, y}, :d), do: {x, y + 1}
  def move({x, y}, :l), do: {x - 1, y}
  def move({x, y}, :r), do: {x + 1, y}

  def add_to_open_set(open_set, new_elem) do
    [new_elem | open_set]
  end

  def check_if_add_direction(open_set, current, direction, data) do
    new_pos = move(current.position, direction)
    w = weight_at(new_pos, data.input)
    tentative_score = Map.get(data.g_map, current.key) + w
    {c1, c2, _} = current.prev_directions
    new_prev_directions = {direction, c1, c2}
    new_key = do_key(new_pos, new_prev_directions)

    if tentative_score <
         Map.get(data.g_map, new_key, 9_999_999_999) do
      f_score = tentative_score + h(new_pos, data.goal)

      neighbor = %{
        position: new_pos,
        prev_directions: new_prev_directions,
        weight: w,
        f: f_score,
        key: new_key
      }

      d2 = %{
        data
        | g_map: Map.put(data.g_map, new_key, tentative_score),
          f_map: Map.put(data.f_map, new_key, f_score),
          came_from: Map.put(data.came_from, new_key, current.key)
      }

      if new_key not in data.in_open_set do
        {
          Heap.push(open_set, neighbor),
          %{d2 | in_open_set: Map.put(d2.in_open_set, new_key, true)}
        }
      else
        {open_set, d2}
      end
    else
      {open_set, data}
    end
  end

  def add_neighbours(open_set, current, data) do
    Enum.reduce([:u, :d, :r, :l], {open_set, data}, fn dir, {s, d} ->
      if direction_possible?(current, dir, data) do
        check_if_add_direction(s, current, dir, d)
      else
        {s, d}
      end
    end)
  end

  def weight_at({x, y}, input) do
    input[y]
    |> Enum.at(x)
  end

  def do_key({x, y}, {d1, d2, d3}) do
    "#{x},#{y},#{d1}#{d2}#{d3}"
  end

  def part1(_args \\ []) do
    input = parse()
    width = input[0] |> Enum.count()
    height = Enum.count(input)

    prev_dir_start = {nil, nil, nil}
    start_position = {0, 0}
    goal = {width - 1, height - 1}

    key = do_key(start_position, prev_dir_start)
    f_score = 0

    data = %{
      width: width,
      height: height,
      goal: goal,
      input: input,
      g_map: Map.put(%{}, key, 0),
      f_map: Map.put(%{}, key, f_score),
      in_open_set: %{key: true},
      came_from: %{}
    }

    Heap.new(fn el1, el2 -> el1.f < el2.f end)
    |> push(%{
      position: start_position,
      prev_directions: prev_dir_start,
      key: key,
      f: f_score,
      weight: weight_at(start_position, input)
    })
    |> a_star(data)
  end

  def part2(_args \\ []) do
  end
end
