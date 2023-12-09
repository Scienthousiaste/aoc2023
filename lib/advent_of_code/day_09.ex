defmodule AdventOfCode.Day09 do
  def input(test? \\ false) do
    if test? do
      """
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
      """
    else
      AdventOfCode.Input.get!(9, 2023)
    end
  end

  def test_part1 do
    part1() == 114
  end

  def parse() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part1(_args \\ []) do
    parse()
    |> Enum.map(&find_next_sequence_value/1)
    |> Enum.sum
  end

  def find_next_sequence_value(numbers) do
    1..Enum.count(numbers)
    |> Enum.reduce_while([numbers], fn _n, [list | _tail] = lists ->
      if finished?(list) do
        {:halt, lists}
      else
        {:cont, [compute_diffs(list) | lists]}
      end
    end)

    |> Enum.reduce(0, fn cur_list, prev ->
      List.last(cur_list) + prev
    end)
  end

  def finished?(numbers) do
    Enum.all?(numbers, &(&1 == 0))
  end

  def compute_diffs(numbers) do
    {_, diffs} = Enum.reduce(numbers, {nil, []}, fn value, {prev, list} ->
      case prev do
        nil -> {value, list}
        prev_value -> {value, [value - prev_value | list]}
      end
    end)

    Enum.reverse(diffs)
  end

  def find_previous_sequence_value(numbers) do
    1..Enum.count(numbers)
    |> Enum.reduce_while([numbers], fn _n, [list | _tail] = lists ->
      if finished?(list) do
        {:halt, lists}
      else
        {:cont, [compute_diffs(list) | lists]}
      end
    end)

    |> Enum.reduce(0, fn cur_list, prev ->
      List.first(cur_list) - prev
    end)
  end

  def part2(_args \\ []) do
    parse()
    |> Enum.map(&find_previous_sequence_value/1)
    |> Enum.sum
  end
end
