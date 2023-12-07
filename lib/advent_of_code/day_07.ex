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
      QQQJA 483
      """
    else
      AdventOfCode.Input.get!(7, 2023)
    end
  end

  def parse do
    input(false)
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
      if is_hand_better?(h1, h2, &category/1, &card_value1/1) do
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

  def is_hand_better?(%{hand: h1}, %{hand: h2}, category, card_value) do
    c1 = category.(h1)
    c2 = category.(h2)

    cond do
      c1 > c2 -> true
      c1 < c2 -> false
      c1 == c2 ->
        Enum.zip(h1, h2)
        |> Enum.reduce_while(false, fn {card1, card2}, acc ->
          cond do
            card1 == card2 -> {:cont, acc}
            is_better?(card1, card2, card_value) -> {:halt, true}
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

  def category2(hand) do
    res = Enum.reduce(hand, %{}, fn char, acc ->
      case Map.get(acc, char) do
        nil -> Map.put(acc, char, 1)
        x -> Map.put(acc, char, x + 1)
      end
    end)

    new_res = if res["J"] do
      nb_jokers = res["J"]
      # en premier, meilleur nombre + meilleurs carte
      other_card_comb = res
      |> Map.drop(["J"])
      |> Map.to_list()
      |> Enum.sort(fn {card1, nb1}, {card2, nb2} ->

        # The given function should compare two arguments, and return true if
        # the first argument precedes or is in the same place as the second one
        cond do
          nb1 > nb2 -> true
          nb2 > nb1 -> false
          true -> not is_better?(card1, card2, &card_value2/1)
        end
      end)


      if other_card_comb == [] do
        res
      else
        [{best_card, best_nb} | rest] = other_card_comb

        sup = [{best_card, best_nb + nb_jokers} | rest]
        |> Map.new()

        sup
      end
    else
      res
    end

    values = Map.values(new_res)
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

  def is_better?(card1, card2, card_value) do
    card_value.(card1) >= card_value.(card2)
  end

  def part2(_args \\[]) do
    res = parse()
    |> Enum.sort(fn h1, h2 ->
      if is_hand_better?(h1, h2, &category2/1, &card_value2/1) do
        false
      else
        true
      end
    end)

    res
    |> Enum.map(&(&1.bid))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {bid, idx}, acc ->
      acc + (bid * (idx + 1))
    end)
  end
end
