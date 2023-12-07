defmodule AdventOfCode.Day07 do

  def card_value1(card) do
    %{
      "2" => 2,
      "3" => 3,
      "4" => 4,
      "5" => 5,
      "6" => 6,
      "7" => 7,
      "8" => 8,
      "9" => 9,
      "T" => 10,
      "J" => 11,
      "Q" => 12,
      "K" => 13,
      "A" => 14
    }
    |> Map.get(card)
  end

  def card_value2(card) do
    %{
      "J" => 1,
      "2" => 2,
      "3" => 3,
      "4" => 4,
      "5" => 5,
      "6" => 6,
      "7" => 7,
      "8" => 8,
      "9" => 9,
      "T" => 10,
      "Q" => 11,
      "K" => 12,
      "A" => 13
    }
    |> Map.get(card)
  end

  def input(test? \\ false) do
    if test? do
      """
        32T3K 765
        T55J5 684
        KK677 28
        KTJJT 220
        JJJJJ 483
      """
    else
      AdventOfCode.Input.get!(7, 2023)
    end
  end

  def parse do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line)
      %{hand: String.split(hand, "", trim: true), bid: String.to_integer(bid)}
    end)
  end

  def part1(_args \\[]) do
    parse()
    |> Enum.sort(fn h1, h2 ->
      # The given function should compare two arguments, and return true if
      # the first argument precedes or is in the same place as the second one.
      if is_hand_better?(h1, h2) do
        false
      else
        true
      end
    end)
    |> Enum.map(&(&1.bid))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {bid, idx}, acc ->
      acc + (bid * (idx + 1))
    end)
  end

  def is_hand_better?(%{hand: h1}, %{hand: h2}) do
    c1 = category(h1)
    c2 = category(h2)


    cond do
      c1 > c2 -> true
      c1 < c2 -> false
      c1 == c2 ->
        Enum.zip(h1, h2)
        |> Enum.reduce_while(false, fn {card1, card2}, acc ->
          cond do
            card1 == card2 -> {:cont, acc}
            is_better?(card1, card2) -> {:halt, true}
            true -> {:halt, false}
          end
        end)
    end
  end

  def category(hand) do
    res = Enum.reduce(hand, %{}, fn char, acc ->
      case Map.get(acc, char) do
        nil -> Map.put(acc, char, 1)
        x -> Map.put(acc, char, x + 1)
      end
    end)

    values = Map.values(res)
    set_values = MapSet.new(values)

    cond do
      MapSet.equal?(set_values, MapSet.new([5])) -> 999
      MapSet.equal?(set_values, MapSet.new([4, 1])) -> 100
      MapSet.equal?(set_values, MapSet.new([2, 3])) -> 50
      MapSet.equal?(set_values, MapSet.new([1, 3])) -> 20
      Enum.count(values) == 3 and MapSet.equal?(set_values, MapSet.new([1, 2])) -> 5
      Enum.count(values) == 4 and MapSet.equal?(set_values, MapSet.new([1, 2])) -> 3
      true -> 1
    end
  end

  def is_better?(card1, card2) do
    card_value1(card1) >= card_value1(card2)
  end

  def part2(_args \\[]) do
  end
end
