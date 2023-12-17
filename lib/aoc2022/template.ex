defmodule AdventOfCode2022.Template do
  def input(test \\ false) do
    if test do
      """

      """
    else
      {:ok, contents} = File.read("lib/aoc2022/day_.txt")
      contents
    end
  end

  def parse() do
    input(true)
    |> String.split("\n", trim: true)
  end

  def part1(_args \\ []) do
  end

  def part2(_args \\ []) do
  end
end
