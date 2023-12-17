defmodule AdventOfCode2022.Day01 do
  def input(test \\ false) do
    if test do
      """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
    else
      {:ok, contents} = File.read("lib/aoc2022/day_01.txt")
      contents
    end
  end

  def parse() do
    input()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn s ->
      String.split(s, "\n", trim: true)
    end)
  end

  @spec part1(any()) :: any()
  def part1(_args \\ []) do
    parse()
    |> Enum.map(fn l ->
      Enum.map(l, fn q -> String.to_integer(q) end)
      |> Enum.sum
    end)
    |> Enum.max
  end

  def part2(_args \\ []) do
    r = parse()
    |> Enum.map(fn l ->
      Enum.map(l, fn q -> String.to_integer(q) end)
      |> Enum.sum
    end)
    |> Enum.sort(:desc)

    Enum.sum([Enum.at(r, 0), Enum.at(r, 1), Enum.at(r, 2)])
  end
end
