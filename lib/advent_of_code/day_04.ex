defmodule AdventOfCode.Day04 do
  @line_regex ~r/Card\s*(?<card_id>\d+): (?<winning_numbers>.*)\|(?<numbers_you_have>.*)/

  def input() do
    _test_input = """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """

    AdventOfCode.Input.get!(4, 2023)
  end

  def parse_data() do
    input()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->

      {card_id, winning_numbers_string, numbers_you_have_string} =
        case Regex.named_captures(@line_regex, line) do
          %{
            "card_id" => card_id,
            "winning_numbers" => winning_numbers_string,
            "numbers_you_have" => numbers_you_have_string
          } ->
            {card_id, winning_numbers_string, numbers_you_have_string}

          _x ->
            require IEx
            IEx.pry()
            {0, "0", "1"}
        end

      winning_numbers =
        winning_numbers_string
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      numbers_you_have =
        numbers_you_have_string
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      %{
        id: card_id,
        winning_numbers: winning_numbers,
        numbers_you_have: numbers_you_have
      }
    end)
  end

  def part1(_args \\ []) do
    parse_data()
    |> Enum.map(fn card ->
      card.numbers_you_have
      |> Enum.reduce(0, fn n, sum ->
        if n in card.winning_numbers do
          case sum do
            0 -> 1
            x -> x * 2
          end
        else
          sum
        end
      end)
    end)
    |> Enum.sum()
  end

  def part2(_args \\ []) do
    [res, _copies] = parse_data()
    |> Enum.reduce([0, %{}], fn card, [total, earned_copies] ->
      # %{id: card_id, winning_numbers: winning_numbers, numbers_you_have: numbers_you_have}

      n_copies_earned = card.numbers_you_have
      |> Enum.reduce(0, fn n, copy_earned ->
        if n in card.winning_numbers, do: copy_earned + 1, else: copy_earned
      end)

      updated_earned_copies = if n_copies_earned > 0 do
        Enum.reduce(1..n_copies_earned, earned_copies, fn x, copies ->
          add_to_copies(copies, x + String.to_integer(card.id), number_of_current_copies(copies, String.to_integer(card.id)))
        end)
      else
        earned_copies
      end
      [total + number_of_current_copies(updated_earned_copies, String.to_integer(card.id)), updated_earned_copies]
    end)
    res
  end

  def add_to_copies(copies, card_id, n) do
    case Map.get(copies, card_id) do
      nil -> Map.put(copies, card_id, n)
      x -> Map.put(copies, card_id, x + n)
    end
  end

  def number_of_current_copies(copies, card_id) do
    case Map.get(copies, card_id) do
      nil -> 1
      x -> x + 1
    end
  end
end
