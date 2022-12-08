defmodule Day5 do

  # stacks of crates
  # The top of the stack is the head of each list
  # Faster do build in code than to write a parser...
  def init_stacks() do
    %{
      "1" => ["P", "D", "Q", "R", "V", "B", "H", "F"],
      "2" => ["V", "W", "Q", "Z", "D", "L"],
      "3" => ["C", "P", "R", "G", "Q", "Z", "L", "H"],
      "4" => ["B", "V", "J", "F", "H", "D", "R"],
      "5" => ["C", "L", "W", "Z"],
      "6" => ["M", "V", "G", "T", "N", "P", "R", "J"],
      "7" => ["S", "B", "M", "V", "L", "R", "J"],
      "8" => ["J", "P", "D"],
      "9" => ["V", "W", "N", "C", "D"],
    }
  end

  def part1() do
    stacks = init_stacks()
    instructions = File.stream!("res/day5.txt") |> Enum.to_list
    result = rearrangement_procedure(instructions, stacks, &move_crates_9000/4)
    res = Enum.join(top_crates(result), "")
    IO.puts ["Part 1: ", res]
  end

  def part2() do
    stacks = init_stacks()
    instructions = File.stream!("res/day5.txt") |> Enum.to_list
    result = rearrangement_procedure(instructions, stacks, &move_crates_9001/4)
    res = Enum.join(top_crates(result), "")
    IO.puts ["Part 2: ", res]
  end

  def move_crates_9000(stacks, num_crates, _from, _to) when num_crates < 1 do
    stacks
  end

  def move_crates_9000(stacks, num_crates, from, to) when num_crates >= 1 do
    new_stacks = move_crate_9000(stacks, from, to)
    move_crates_9000(new_stacks, num_crates - 1, from, to)
  end

  def move_crate_9000(stacks, from, to) do
    {crate, new_stacks} = Map.get_and_update!(stacks, from, fn [head | tail] ->
      {head, tail}
    end)
    Map.update(new_stacks, to, [crate], fn existing_value -> [crate | existing_value] end)
  end

  def move_crates_9001(stacks, num_crates, from, to) when num_crates >= 1 do
    {crates, new_stacks} = Map.get_and_update!(stacks, from, fn stack ->
      Enum.split(stack, num_crates)
    end)
    Map.update(new_stacks, to, crates, fn existing_value -> crates ++ existing_value end)
  end

  def rearrangement_procedure([], stacks, _move_fun) do
    stacks
  end

  def rearrangement_procedure([instruction | rest_of_instructions], stacks, move_fun) do
    [_, num_crates, from, to] = Regex.run(~r/move (\d+) from (\d+) to (\d+)/, instruction)
    rearranged_stacks = move_fun.(stacks, String.to_integer(num_crates), from, to)
    rearrangement_procedure(rest_of_instructions, rearranged_stacks, move_fun)
  end

  # Returns a sorted list of all top crates in all stacks
  def top_crates(stacks) do
    keys = Enum.sort(Map.keys(stacks))
    top_crates(stacks, keys)
  end

  def top_crates(_stacks, []) do
    []
  end

  def top_crates(stacks, [key | rest_keys]) do
    [crate | _] = Map.get(stacks, key)
    [crate | top_crates(stacks, rest_keys)]
  end

  def test_it() do
    %{"1" => [], "2" => ["a"]} = move_crate_9000(%{"1" => ["a"]}, "1", "2")
    %{"1" => ["b"], "2" => ["a", "c", "d"]} = move_crate_9000(%{"1" => ["a", "b"], "2" => ["c", "d"]}, "1", "2")
    %{"1" => [], "2" => ["b", "a"]} = move_crates_9000(%{"1" => ["a", "b"]}, 2, "1", "2")
    "ace" = Enum.join(top_crates(%{"1" => ["a", "b"], "2" => ["c", "d"], "3" => ["e", "f"]}), "")

    #    [D]
    #[N] [C]
    #[Z] [M] [P]
    # 1   2   3
    stacks = %{
      "1" => ["N", "Z"],
      "2" => ["D", "C", "M"],
      "3" => ["P"]
    }
    instructions = [
      "move 1 from 2 to 1",
      "move 3 from 1 to 3",
      "move 2 from 2 to 1",
      "move 1 from 1 to 2"
    ]

    # Testing the 9000 model
    result = rearrangement_procedure(instructions, stacks, &move_crates_9000/4)
    %{
      "1" => ["C"],
      "2" => ["M"],
      "3" => ["Z", "N", "D", "P"]
    } = result
    "CMZ" = Enum.join(top_crates(result), "")

    # Testing the 9001 model
    result = rearrangement_procedure(instructions, stacks, &move_crates_9001/4)
    %{
      "1" => ["M"],
      "2" => ["C"],
      "3" => ["D", "N", "Z", "P"]
    } = result
    "MCD" = Enum.join(top_crates(result), "")
  end

end

IO.puts "Day 5"
Day5.test_it()
Day5.part1()
Day5.part2()