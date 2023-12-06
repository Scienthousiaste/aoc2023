defmodule AdventOfCode.Day06 do
  def input() do
    # test_input = """
    #   Time:      7  15   30
    #   Distance:  9  40  200
    # """

    # Time:        53     89     76     98
    # Distance:   313   1090   1214   1201
    AdventOfCode.Input.get!(6, 2023)
  end

  def parse_line(line, start_regex) do
    line
    |> String.split(start_regex, trim: true)
    |> List.first
    |> String.split
    |> Enum.map(& String.to_integer(&1))
  end

  def parse() do
    [times_line, distances_line] = input()
    |> String.split("\n", trim: true)

    times = parse_line(times_line, ~r/\s*Time:/)
    distances = parse_line(distances_line, ~r/\s*Distance:/)

    Enum.zip(times, distances)
  end

  def parse_part2 do
    [times_line, distances_line] = input()
    |> String.split("\n", trim: true)

    time = parse_line(times_line, ~r/\s*Time:/) |> Enum.join |> String.to_integer
    distance = parse_line(distances_line, ~r/\s*Distance:/) |> Enum.join |> String.to_integer

    [time, distance]
  end

  def part1(_args \\[]) do
    parse()
    |> Enum.map(&count_winning_solutions/1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def count_winning_solutions({duration, distance_to_beat}) do

    0..duration
    |> Enum.map(fn x ->
      speed = x
      moving_duration = duration - x
      distance_traveled = speed * moving_duration

      distance_traveled > distance_to_beat
    end)
    |> Enum.filter(&(&1))
    |> Enum.count
  end

  def part2(_args \\ []) do
    [time, distance] = parse_part2()

    count_winning_solutions({time, distance})
  end
end
