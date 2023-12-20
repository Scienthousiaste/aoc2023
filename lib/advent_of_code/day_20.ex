defmodule AdventOfCode.Day20 do
  def input(test \\ false) do
    if test do

      """
      broadcaster -> a, b, c
      %a -> b
      %b -> c
      %c -> inv
      &inv -> a
      """
      # """
      # broadcaster -> a
      # %a -> inv, con
      # &inv -> b
      # %b -> con
      # &con -> output
      # """
    else
      {:ok, contents} = File.read("lib/advent_of_code/day_20_input.txt")
      contents
    end
  end

  def init_state(:flip), do: :off
  def init_state(:and), do: :to_init
  def init_state(:cast), do: nil

  def parse_module(line) do
    module_regex = ~r/(?<prefix>[%&]?)(?<name>[a-z]*) -> (?<outputs>.*)/

    %{"prefix" => prefix, "name" => name, "outputs" => outputs} =
      Regex.named_captures(module_regex, line)

    type =
      case prefix do
        "%" -> :flip
        "&" -> :and
        "" -> :cast
      end

    {name,
     %{
       name: name,
       type: type,
       outputs: String.split(outputs, ",") |> Enum.map(&String.trim(&1)),
       state: init_state(type)
     }}
  end

  def button_module(modules) do
    {b_name, _broadcaster} =
      modules
      |> Enum.find(fn {_n, m} -> m.type == :cast end)

    {"button",
     %{
       name: "button",
       type: :cast,
       outputs: [b_name],
       state: nil
     }}
  end

  def init_conjunction_modules(modules) do
    Enum.map(modules, fn {n, m} ->
      if m.type == :and do
        inputs =
          modules
          |> Enum.map(fn {_n, m} -> m end)
          |> Enum.filter(&(m.name in &1.outputs))
          |> Enum.map(&{&1.name, :low})
          |> Map.new()

        new = Map.put(m, :state, inputs)
        {new.name, new}
      else
        {n, m}
      end
    end)
  end

  def parse() do
    modules =
      input(true)
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_module/1)

    [button_module(modules) | init_conjunction_modules(modules)]
    |> Map.new()
  end

  def count_pulse(data, :low) do
    Map.update(data, :n_low, 0, &(&1 + 1))
  end

  def count_pulse(data, :high) do
    Map.update(data, :n_high, 0, &(&1 + 1))
  end

  def process_flip(data, :high, _module), do: {data, []}

  def process_flip(data, :low, module) do
    state = data.state
    {next_state, pulses} =
      case module.state do
        :off ->
          {Map.update(state, module.name, nil, fn m ->
             Map.put(m, :state, :on)
           end), Enum.map(module.outputs, fn m -> {:high, m, module.name} end)}

        :on ->
          {Map.update(state, module.name, nil, fn m -> Map.put(m, :state, :off) end),
           Enum.map(module.outputs, fn m -> {:low, m, module.name} end)}
      end

    {Map.put(data, :state, next_state), pulses}
  end

  def process_and(data, pulse_type, module, sender) do
    # remember the type of the most recent pulse received from each of their connected input modules; they initially default to remembering a low pulse for each input. When a pulse is received, the conjunction module first updates its memory for that input. Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.

    state = data.state

    next_state = Map.update(state, module.name, nil, fn m ->
      Map.update(m, :state, nil, fn s -> Map.put(s, sender, pulse_type) end)
    end)

    response = if Enum.all?(next_state[module.name].state, &(&1 == :high)) do
      :low
    else
      :high
    end

    {Map.put(data, :state, next_state), Enum.map(module.outputs, fn m -> {response, m, module.name} end)}
  end

  def process_with_module(data, _, nil, _) do
    # deal with "output"
    {data, []}
  end
  def process_with_module(data, pulse_type, module, sender) do
    case module.type do
      :cast -> {data, Enum.map(module.outputs, fn m -> {:low, m, module.name} end)}
      :flip -> process_flip(data, pulse_type, module)
      :and -> process_and(data, pulse_type, module, sender)
    end
  end

  def process_pulse({hl, module, sender}, data) do
    state = data.state
    next_m = Map.get(state, module)

    data
    |> count_pulse(hl)
    |> process_with_module(hl, next_m, sender)
  end

  def push_button(data) do
    Enum.reduce_while(1..100_000, {data, [{:low, "button", nil}]}, fn _i, {state, pulses} ->
      if pulses == [] do
        {:halt, state}
      else

        {next_state, next_pulses} =
          Enum.reduce(pulses, {state, []}, fn pulse, {cur_state, list} ->
            {st, p} = process_pulse(pulse, cur_state)
            {st, list ++ p}
          end)

        {:cont, {next_state, next_pulses}}
      end
    end)
  end

  def part1(_args \\ []) do
    initial_state = parse()


    res =
      Enum.reduce(1..1000, %{n_low: 0, n_high: 0, state: initial_state}, fn _i, data ->
        push_button(data)
      end)

    require IEx
    IEx.pry()
    res.n_low * res.n_high
  end

  def part2(_args \\ []) do
  end
end
