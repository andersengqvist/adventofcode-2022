Code.require_file("tree.exs", "./lib")

defmodule Valve do

  defstruct [:label, :flow_rate, :tunnels]

  def new(label, flow_rate, tunnels) do
    %Valve{label: label, flow_rate: flow_rate, tunnels: tunnels}
  end

end

defmodule Valves do

  defstruct [:valve_map, :openable_valves]

  def new(valve_list) do
    valve_map = Enum.into(valve_list, %{}, fn valve -> {valve.label, valve} end)
    openable_valves = Enum.count(valve_list, fn valve -> valve.flow_rate > 0 end)
    %Valves{valve_map: valve_map, openable_valves: openable_valves}
  end

  def openable_valves(valves) do
    valves.openable_valves
  end

  def flow_rate(valves, label) do
    Map.get(valves.valve_map, label).flow_rate
  end

  def tunnels(valves, label) do
    Map.get(valves.valve_map, label).tunnels
  end

end

defmodule ValveBuilder do

  def build(input) do
    # Enum.into(%{a: 1, b: 2}, %{c: 3}, fn {k, v} -> {k, v * 2} end)
    valve_list = input
    |> Enum.map(&build_valve/1)
    Valves.new(valve_list)
  end

  # Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
  # Valve HH has flow rate=22; tunnel leads to valve GG
  def build_valve(input) do
    [_, label, flow_rate, tunnel_str] = Regex.run(~r/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/, input)
    tunnels = String.split(tunnel_str, ",", trim: true) |> Enum.map(&String.trim/1)
    Valve.new(label, String.to_integer(flow_rate), tunnels)
  end
end

defmodule Part1State do

  defstruct [:at_valve, minute: 1, visited: MapSet.new(), open_valves: MapSet.new()]

  def new(at_valve) do
    %Part1State{at_valve: at_valve}
  end

  def opened_valves(state) do
    MapSet.size(state.open_valves)
  end

  def is_valve_closed?(state) do
    !MapSet.member?(state.open_valves, state.at_valve)
  end

  def is_not_visited?(state, valve) do
    !MapSet.member?(state.visited, valve)
  end

end
defmodule Part1 do
  @behaviour MaxGameTree

  def actions(valves, state) do
    if Part1State.opened_valves(state) == Valves.openable_valves(valves) do
      []
    else
      #IO.inspect state
      flow_rate = Valves.flow_rate(valves, state.at_valve)
      open_valve_actions = if flow_rate > 0 and Part1State.is_valve_closed?(state) do
        [{{:open_valve}, flow_rate * (30 - state.minute)}]
      else
        []
      end
      move_actions = Valves.tunnels(valves, state.at_valve)
      |> Enum.filter(fn valve -> Part1State.is_not_visited?(state, valve) end)
      |> Enum.map(fn valve -> {{:move, valve}, 0} end)
      open_valve_actions ++ move_actions
    end
  end

  def apply_action(_valves, state, {:move, to_valve}) do
    move(state, to_valve)
  end

  def apply_action(_valves, state, {:open_valve}) do
    open_valve(state)
  end

  def move(state, to_valve) do
    new_visited = MapSet.put(state.visited, state.at_valve)
    %Part1State{state | at_valve: to_valve, minute: state.minute + 1, visited: new_visited}
  end

  def open_valve(state) do
    new_open_valves = MapSet.put(state.open_valves, state.at_valve)
    %Part1State{state | minute: state.minute + 1, visited: MapSet.new(), open_valves: new_open_valves}
  end
end

defmodule Part2State do

  defstruct [:my_pos, :ele_pos, minute: 1, my_visited: MapSet.new(), ele_visited: MapSet.new(), open_valves: MapSet.new()]

  def new(at_valve) do
    %Part2State{my_pos: at_valve, ele_pos: at_valve}
  end

  def opened_valves(state) do
    MapSet.size(state.open_valves)
  end

  def is_valve_closed?(state, valve) do
    !MapSet.member?(state.open_valves, valve)
  end

  def is_not_visited?(state, valve) do
    !(MapSet.member?(state.my_visited, valve) or MapSet.member?(state.ele_visited, valve))
  end

end
defmodule Part2 do
  @behaviour MaxGameTree

  def actions(valves, state) do
    if Part2State.opened_valves(state) == Valves.openable_valves(valves) do
      []
    else
      nested_actions = for {my_action, my_score} <- my_actions(valves, state) do
        new_state = apply_my_action(state, my_action)
        for {ele_action, ele_score} <- ele_actions(valves, new_state) do
          {{my_action, ele_action}, my_score + ele_score}
        end
      end
      List.flatten(nested_actions)
    end
  end

  def my_actions(valves, state) do
    #IO.inspect state
    flow_rate = Valves.flow_rate(valves, state.my_pos)
    open_valve_actions = if flow_rate > 0 and Part2State.is_valve_closed?(state, state.my_pos) do
      [{{:open_valve}, flow_rate * (26 - state.minute)}]
    else
      []
    end
    move_actions = Valves.tunnels(valves, state.my_pos)
                   |> Enum.filter(fn valve -> Part2State.is_not_visited?(state, valve) end)
                   |> Enum.map(fn valve -> {{:move, valve}, 0} end)
    open_valve_actions ++ move_actions
  end

  def ele_actions(valves, state) do
    #IO.inspect state
    flow_rate = Valves.flow_rate(valves, state.ele_pos)
    open_valve_actions = if flow_rate > 0 and Part2State.is_valve_closed?(state, state.ele_pos) do
      [{{:open_valve}, flow_rate * (26 - state.minute)}]
    else
      []
    end
    move_actions = Valves.tunnels(valves, state.ele_pos)
                   |> Enum.filter(fn valve -> Part2State.is_not_visited?(state, valve) end)
                   |> Enum.filter(fn valve -> state.my_pos != valve end)
                   |> Enum.map(fn valve -> {{:move, valve}, 0} end)
    open_valve_actions ++ move_actions
  end

  def apply_action(_valves, state, {my_action, ele_action}) do
    new_state = apply_my_action(state, my_action)
    new_state = apply_ele_action(new_state, ele_action)
    %Part2State{new_state | minute: state.minute + 1}
  end

  def apply_my_action(state, {:move, to_valve}) do
    new_visited = MapSet.put(state.my_visited, state.my_pos)
    %Part2State{state | my_pos: to_valve, my_visited: new_visited}
  end

  def apply_my_action(state, {:open_valve}) do
    new_open_valves = MapSet.put(state.open_valves, state.my_pos)
    %Part2State{state | my_visited: MapSet.new(), open_valves: new_open_valves}
  end

  def apply_ele_action(state, {:move, to_valve}) do
    new_visited = MapSet.put(state.ele_visited, state.ele_pos)
    %Part2State{state | ele_pos: to_valve, ele_visited: new_visited}
  end

  def apply_ele_action(state, {:open_valve}) do
    new_open_valves = MapSet.put(state.open_valves, state.ele_pos)
    %Part2State{state | ele_visited: MapSet.new(), open_valves: new_open_valves}
  end

end

defmodule Day16 do

  def part1() do
    input = File.read!("res/day16.txt") |> String.split("\n", trim: true)
    valves = ValveBuilder.build(input)
    {res, _} = MaxGameTree.Search.max(Part1, valves, Part1State.new("AA"), 10)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day16.txt") |> String.split("\n", trim: true)
    valves = ValveBuilder.build(input)
    {res, _} = MaxGameTree.Search.max(Part2, valves, Part2State.new("AA"), 26)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    %Valve{flow_rate: 0, label: "AA", tunnels: ["DD", "II", "BB"]} =
      ValveBuilder.build_valve("Valve AA has flow rate=0; tunnels lead to valves DD, II, BB")

    %Valve{flow_rate: 22, label: "HH", tunnels: ["GG"]} =
      ValveBuilder.build_valve("Valve HH has flow rate=22; tunnel leads to valve GG")

    #IO.inspect ValveBuilder.build_valve("Valve HH has flow rate=22; tunnel leads to valve ")
    input = [
      "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
      "Valve BB has flow rate=13; tunnels lead to valves CC, AA",
      "Valve CC has flow rate=2; tunnels lead to valves DD, BB",
      "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
      "Valve EE has flow rate=3; tunnels lead to valves FF, DD",
      "Valve FF has flow rate=0; tunnels lead to valves EE, GG",
      "Valve GG has flow rate=0; tunnels lead to valves FF, HH",
      "Valve HH has flow rate=22; tunnel leads to valve GG",
      "Valve II has flow rate=0; tunnels lead to valves AA, JJ",
      "Valve JJ has flow rate=21; tunnel leads to valve II"
    ]
    valves = ValveBuilder.build(input)
    #IO.inspect valves
    res = MaxGameTree.Search.max(Part1, valves, Part1State.new("AA"), 30)
    #IO.inspect res
    {1651, _} = res
    res = MaxGameTree.Search.max(Part2, valves, Part2State.new("AA"), 26)
    #IO.inspect res
    {1707, _} = res
  end

end

IO.puts "Day 16"
Day16.test_it()
Day16.part1()
Day16.part2()