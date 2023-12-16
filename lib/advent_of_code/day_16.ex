defmodule AdventOfCode.Day16 do
  def input(test \\ false) do
    if test do
      """
      .|...\\....
      |.-.\\.....
      .....|-...
      ........|.
      ..........
      .........\\
      ..../.\\\\..
      .-.-/..|..
      .|....-|.\
      ..//.|....
      """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_16_input.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.with_index(fn e, index -> {index, e} end)
    |> Map.new()
  end

  @spec c_at(nil | maybe_improper_list() | map(), {integer(), any()}) :: nil | binary()
  def c_at(input, {x, y}) do
    input[y]
    |> String.at(x)
  end

  def next_position({x, y}, :right, input) do
    if x + 1 < String.length(input[0]) do
      {x + 1, y}
    else
      nil
    end
  end

  def next_position({x, y}, :left, _input) do
    if x - 1 >= 0 do
      {x - 1, y}
    else
      nil
    end
  end

  def next_position({x, y}, :up, _input) do
    if y - 1 >= 0 do
      {x, y - 1}
    else
      nil
    end
  end

  def next_position({x, y}, :down, input) do
    if y + 1 < Enum.count(input) do
      {x, y + 1}
    else
      nil
    end
  end

  def next_ray_position_no_new_ray(p, d, input) do
    {next_ray_position(p, d, input), nil}
  end

  def next_ray_position(p, d, input) do
    case next_position(p, d, input) do
      nil -> nil
      position -> %{position: position, direction: d}
    end
  end

  def move_ray(%{position: p, direction: d}, ".", input) do
    next_ray_position_no_new_ray(p, d, input)
  end

  def move_ray(%{position: p, direction: d}, "-", input) when d in [:right, :left] do
    next_ray_position_no_new_ray(p, d, input)
  end

  def move_ray(%{position: p, direction: d}, "-", input) when d in [:up, :down] do
    {next_ray_position(p, :right, input), next_ray_position(p, :left, input)}
  end

  def move_ray(%{position: p, direction: d}, "|", input) when d in [:up, :down] do
    next_ray_position_no_new_ray(p, d, input)
  end

  def move_ray(%{position: p, direction: d}, "|", input) when d in [:left, :right] do
    {next_ray_position(p, :up, input), next_ray_position(p, :down, input)}
  end

  def move_ray(%{position: p, direction: d}, "/", input) do
    case d do
      :right -> next_ray_position_no_new_ray(p, :up, input)
      :left -> next_ray_position_no_new_ray(p, :down, input)
      :up -> next_ray_position_no_new_ray(p, :right, input)
      :down -> next_ray_position_no_new_ray(p, :left, input)
    end
  end

  def move_ray(%{position: p, direction: d}, "\\", input) do
    case d do
      :right -> next_ray_position_no_new_ray(p, :down, input)
      :left -> next_ray_position_no_new_ray(p, :up, input)
      :up -> next_ray_position_no_new_ray(p, :left, input)
      :down -> next_ray_position_no_new_ray(p, :right, input)
    end
  end

  def send_ray(input, ray, pre_places_crossed, pre_energized) do
    if not MapSet.member?(pre_places_crossed, {ray.position, ray.direction}) do
      places_crossed = MapSet.put(pre_places_crossed, {ray.position, ray.direction})
      energized = MapSet.put(pre_energized, ray.position)

      {next_ray_state, new_ray} = move_ray(ray, c_at(input, ray.position), input)

      {next_places_crossed, next_energized} =
        if next_ray_state do
          case send_ray(input, next_ray_state, places_crossed, energized) do
            nil -> {places_crossed, energized}
            x -> x
          end
        else
          {places_crossed, energized}
        end

      if new_ray do
        case send_ray(input, new_ray, next_places_crossed, next_energized) do
          nil -> {next_places_crossed, next_energized}
          x -> x
        end
      else
        {next_places_crossed, next_energized}
      end
    end
  end

  def part1(_args \\ []) do
    {_crossed, energized} =
      parse()
      |> send_ray(
        %{position: {0, 0}, direction: :right},
        MapSet.new([{{0, 0}, {:right}}]),
        MapSet.new([{0, 0}])
      )

    require IEx
    IEx.pry()
    MapSet.size(energized)
  end

  def part2(_args \\ []) do
    input = parse()

    height = Enum.count(input)
    width = String.length(input[0])

    up_downs = for x <- 0..(width - 1) do
      [{{x, 0}, :down}, {{x, height - 1}, :up}]
    end

    left_rights = for y <- 0..(height - 1) do
      [{{0, y}, :right}, {{width - 1, y}, :left}]
    end

    res = List.flatten(up_downs ++ left_rights)
    |> Enum.map(fn {pos, dir} ->
      {_crossed, energized} = input
      |> send_ray(
        %{position: pos, direction: dir},
        MapSet.new([{pos, {dir}}]),
        MapSet.new([pos])
      )

      MapSet.size(energized)
    end)

    res
    |> Enum.max

  end
end
