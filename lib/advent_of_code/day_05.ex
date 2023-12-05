defmodule AdventOfCode.Day05 do

  def input() do
    """
      seeds: 79 14 55 13

      seed-to-soil map:
      50 98 2
      52 50 48

      soil-to-fertilizer map:
      0 15 37
      37 52 2
      39 0 15

      fertilizer-to-water map:
      49 53 8
      0 11 42
      42 0 7
      57 7 4

      water-to-light map:
      88 18 7
      18 25 70

      light-to-temperature map:
      45 77 23
      81 45 19
      68 64 13

      temperature-to-humidity map:
      0 69 1
      1 0 69

      humidity-to-location map:
      60 56 37
      56 93 4
    """
    # AdventOfCode.Input.get!(5, 2023)
  end

  def parse() do
    {data, _} = input()
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{maps: [], current_map: []}, false}, fn raw_line, {data, expects_map?} ->
      line = String.trim(raw_line)
      cond do
        String.starts_with?(line, "seeds:") -> {add_seeds(data, line), false}
        String.match?(line, ~r/.*map:/) -> {finish_current_map(data, line), true}
        expects_map? -> {add_line_to_current_map(line, data), true}
      end
    end)

    finish_current_map(data, "")
  end

  def add_line_to_current_map(line, data) do
    data
    |> Map.update(:current_map, [], fn prev ->
      [parse_map_line(line, data.map_label) | prev]
    end)
  end

  def parse_map_line(line, label) do
    regex = ~r/\s*(?<range_1>\d+)\s*(?<range_2>\d+)\s*(?<range_2_length>\d+)\s*/
    %{
      "range_1" => destination,
      "range_2" => source,
      "range_2_length" => range_length
    } = Regex.named_captures(regex, line)
    %{
      start_range: String.to_integer(source),
      end_range: String.to_integer(source) + String.to_integer(range_length) - 1,
      to_add:  String.to_integer(destination) - String.to_integer(source),
      label: label
    }
  end

  def finish_current_map(data, "") do
    if (data.current_map !== []) do
      data
      |> Map.update(:maps, [], fn mp -> mp ++ [data.current_map] end)
      |> Map.put(:current_map, [])
    else
      data
    end
  end

  def finish_current_map(data, line) do
    %{"label" => label} = Regex.named_captures(~r/.*-to-(?<label>[a-z]*) *map:/, line)
    data2 = data |> Map.put(:map_label, label)

    if (data2.current_map !== []) do
      data2
      |> Map.put(:maps, data.maps ++ [data2.current_map])
      |> Map.put(:current_map, [])
    else
      data2
    end
  end

  def add_seeds(data, line) do
    seeds = line
    |> String.split("seeds:", trim: true)
    |> Enum.at(0)
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer(&1))

    Map.put(data, :seeds, seeds)
  end

  def part1(_args \\ []) do
    %{maps: maps, seeds: seeds} = parse()

    # IO.inspect(maps)

    seeds
    |> Enum.map(fn seed ->

      # IO.inspect("Seed #{seed}")
      Enum.reduce(maps, seed, fn map, n ->
        res = Enum.reduce_while(map, n, fn range, nn ->
          if nn >= range.start_range && nn <= range.end_range do
            {:halt, nn + range.to_add}
          else
            {:cont, nn}
          end
        end)
        # IO.inspect("#{Enum.at(map, 0).label} - #{res}")
        res
      end)
    end)
    |> Enum.min

  end

  def compute_seed(maps, seed) do
    Enum.reduce(maps, seed, fn map, n ->
      Enum.reduce_while(map, n, fn range, nn ->
        if nn >= range.start_range && nn <= range.end_range do
          {:halt, nn + range.to_add}
        else
          {:cont, nn}
        end
      end)
    end)
  end

  def part2_brute_force(_args \\ []) do
    %{maps: maps, seeds: seed_ranges} = parse()

    {sr, _, _} = seed_ranges
    |> Enum.reduce({[], nil, true}, fn sr, {seeds, start, start?} ->
      if start? do
        {seeds, sr, false}
      else
        {seeds ++ [start..(start + sr - 1)], nil, true}
      end
    end)

    result = sr
    |> Enum.with_index
    |> Enum.reduce(9999999999, fn {current_range, index}, min ->
      res = current_range
      |> Enum.reduce(min, fn seed, cur_min ->
        case compute_seed(maps, seed) do
          x when x < cur_min -> x
          _ -> cur_min
        end
      end)
      IO.inspect("end of range #{index}, #{res}")
      res
    end)
    result
  end

  def part2(_args \\[]) do
    %{maps: maps, seeds: seeds} = parse()

    Enum.reduce(maps, make_seed_ranges(seeds), fn map, ranges ->

      Enum.reduce(ranges, [], fn current_range, range_list ->

        Enum.reduce(map, [current_range], fn map, ranges ->

          map_range = map.start_range..map.end_range

          require IEx; IEx.pry
          cond do
            Range.disjoint?(current_range, map_range)
              -> ranges
            true -> ranges
          end

        end)

      end)
    end)
  end

  def make_seed_ranges(seeds) do
    {seed_ranges, _, _} = seeds
    |> Enum.reduce({[], nil, true}, fn sr, {seeds, start, start?} ->
      if start? do
        {seeds, sr, false}
      else
        {seeds ++ [start..(start + sr - 1)], nil, true}
      end
    end)
    seed_ranges
  end
end
