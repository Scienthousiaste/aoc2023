defmodule AdventOfCode.Day01 do
  def part1(_args) do
    AdventOfCode.Input.get!(1, 2023)
    |> String.split("\n", trim: true)
    |> Enum.map(fn st ->
      st
      |> String.codepoints()
      |> Enum.filter(fn char -> char >= "0" and char <= "9" end)
    end)
    |> Enum.map(fn ar ->
      String.to_integer("#{Enum.at(ar, 0)}#{Enum.at(ar, -1)}")
    end)
    |> Enum.sum()
  end

  def part2(_args) do
    AdventOfCode.Input.get!(1, 2023)
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> replace_numbers_with_digits(x) end)
    |> Enum.map(fn st ->
      st
      |> String.codepoints()
      |> Enum.filter(fn char -> char >= "0" and char <= "9" end)
    end)
    |> Enum.map(fn ar ->
      String.to_integer("#{Enum.at(ar, 0)}#{Enum.at(ar, -1)}")
    end)
    |> Enum.sum()
  end

  @numbers ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  def replace_numbers_with_digits(str) do
    @numbers
    |> Enum.with_index()
    |> Enum.reduce(str, fn {num_letters, digit}, acc ->
      String.replace(acc, num_letters, "#{String.first(num_letters)}#{digit + 1}#{String.last(num_letters)}")
    end)
  end
end
