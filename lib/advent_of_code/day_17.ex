defmodule AdventOfCode.Day17 do
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
    input(true)
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn e, idx -> {idx, e} end)
    |> Enum.map(fn {i, e} ->
      {i, e |> String.split("", trim: true) |> Enum.map(&String.to_integer(&1))}
    end)
    |> Map.new()
  end

  def extract_min_weight([h | tail], data) do
    {h, tail, %{data | in_open_set: Map.delete(data.in_open_set, h.key)}}
  end

  def a_star(open_set, data) do
    if Enum.count(open_set) == 0 do
      require IEx; IEx.pry
    end
    {current, open_set, data} = extract_min_weight(open_set, data)

    if current.position == data.goal do
      require IEx; IEx.pry
      # Map.get(data.g_map, "12,12,right,down,down") donne bien 102...
      # alors que Map.get(data.g_map, "12,12,down,down,down") donne 101, mais sensé
      # pas être possible


      # data.g_map(data.goal)

      # require IEx
      # IEx.pry()

      # first try : i had only right of 2 times the same direction
      # Took a while, and got 877, too high

      # optimisations :
      # - properly implement priority queue
      # - not put directions in keys? Will it mean that I won't recheck as much?
      # Maybe it won't matter at all?

      # IO.inspect(current)
      # no need to reconstruct path, I just want the weight
      {next_open_set, next_data} = add_neighbours(open_set, current, data)
      a_star(next_open_set, next_data)
    else
      {next_open_set, next_data} = add_neighbours(open_set, current, data)
      a_star(next_open_set, next_data)
    end
  end

  def opposite(:up), do: :down
  def opposite(:down), do: :up
  def opposite(:right), do: :left
  def opposite(:left), do: :right

  def direction_possible?(current, dir, data) do
    prev = current.prev_directions
    opposite_dir = opposite(dir)
    {x, y} = current.position

    cond do
      match?({^dir, ^dir, ^dir}, prev) -> false
      match?({^opposite_dir, _}, prev) -> false
      dir == :up and y - 1 < 0 -> false
      dir == :down and y + 1 >= data.height -> false
      dir == :left and x - 1 < 0 -> false
      dir == :right and x + 1 >= data.width -> false
      true -> true
    end
  end

  def sort_priority_queue(set) do
    Enum.sort_by(set, &(&1.f), :asc)
  end

  def h({x_pos, y_pos}, {x_goal, y_goal}) do
    (x_goal - x_pos + (y_goal - y_pos))
  end

  def move({x, y}, :up), do: {x, y - 1}
  def move({x, y}, :down), do: {x, y + 1}
  def move({x, y}, :left), do: {x - 1, y}
  def move({x, y}, :right), do: {x + 1, y}

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
          f_map: Map.put(data.f_map, new_key, f_score)
      }

      if new_key not in data.in_open_set do
        {
          add_to_open_set(open_set, neighbor),
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
    {unsorted, d} =
      Enum.reduce([:up, :down, :right, :left], {open_set, data}, fn dir, {s, d} ->
        if direction_possible?(current, dir, data) do
          check_if_add_direction(s, current, dir, d)
        else
          {s, d}
        end
      end)

    {sort_priority_queue(unsorted), d}
  end

  def weight_at({x, y}, input) do
    input[y]
    |> Enum.at(x)
  end

  def do_key({x, y}, {d1, d2, d3}) do
    "#{x},#{y},#{d1},#{d2},#{d3}"
  end
  # def do_key({x, y}, _x) do
  #   "#{x},#{y}"
  # end

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
      f: f_score,
      in_open_set: %{key: true}
    }

    a_star(
      [
        %{
          position: start_position,
          prev_directions: prev_dir_start,
          key: key,
          weight: weight_at(start_position, input)
        }
      ],
      data
    )
  end

  def part2(_args \\ []) do
  end
end
