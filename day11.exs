defmodule Monkey do
  # wlf = worry level function
  defstruct [:name, :items, :operation, :wlf, :test, :true_case, :false_case, num_inspected: 0]

  def spawn(name, items, operation, wlf, test, true_case, false_case) do
    monkey = new(name, items, operation, wlf, test, true_case, false_case)
    pid = spawn_link(fn -> loop(monkey) end)
    if Enum.member?(Process.registered(), name) do
      Process.unregister(name)
    end
    Process.register(pid, name)
  end

  defp new(name, items, operation, wlf, test, true_case, false_case) do
    %Monkey{
      name: name,
      items: :queue.from_list(items),
      operation: operation,
      wlf: wlf,
      test: test,
      true_case: true_case,
      false_case: false_case
    }
  end

  defp loop(monkey) do
    receive do
      {:inspect, caller} ->
        new_monkey = inspect_items(monkey.items, 0, monkey)
        send(caller, {:inspect_done, new_monkey.num_inspected})
        loop(new_monkey)
      {:catch, item} ->
        loop(%Monkey{monkey | items: :queue.in(item, monkey.items)})
    end
  end

  defp inspect_items({[], []}, num_inspected, monkey) do
    %Monkey{monkey | items: :queue.new(), num_inspected: monkey.num_inspected + num_inspected}
  end

  defp inspect_items(items, num_inspected, monkey) do
    {{:value, item}, new_items} = :queue.out(items)
    new_worry_level = monkey.operation.(item)
    new_worry_level = monkey.wlf.(new_worry_level)
    if monkey.test.(new_worry_level) do
      send(monkey.true_case, {:catch, new_worry_level})
    else
      send(monkey.false_case, {:catch, new_worry_level})
    end
    inspect_items(new_items, num_inspected + 1, monkey)
  end

end

defmodule Day11 do

  def part1() do
    monkeys = monkeys(&(trunc(Float.floor(&1 / 3))))
    inspect_list = do_rounds(monkeys, 1, 20)
    res = inspect_list
            |> Enum.sort
            |> Enum.take(-2)
            |> Enum.reduce(fn x, acc -> x * acc end)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    monkeys = monkeys(&(rem(&1, 9699690)))
    inspect_list = do_rounds(monkeys, 1, 10000)
    res = inspect_list
          |> Enum.sort
          |> Enum.take(-2)
          |> Enum.reduce(fn x, acc -> x * acc end)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def do_round([], inspect_list) do
    inspect_list
  end
  def do_round([monkey_name | rest], inspect_list) do
    send(monkey_name, {:inspect, self()})
    inspected = receive do
      {:inspect_done, num_inspected} ->
        num_inspected
    end
    do_round(rest, [inspected | inspect_list])
  end

  def do_rounds(monkeys, curr_round, num_rounds) when curr_round == num_rounds do
    result = do_round(monkeys, [])
    result
  end
  def do_rounds(monkeys, curr_round, num_rounds) do
    do_round(monkeys, [])
    do_rounds(monkeys, curr_round + 1, num_rounds)
  end

  def monkeys(wlf) do
    Monkey.spawn(:m0, [72, 97], &(&1 * 13), wlf, &(rem(&1, 19) == 0), :m5, :m6)
    Monkey.spawn(:m1, [55, 70, 90, 74, 95], &(&1 * &1), wlf, &(rem(&1, 7) == 0), :m5, :m0)
    Monkey.spawn(:m2, [74, 97, 66, 57], &(&1 + 6), wlf, &(rem(&1, 17) == 0), :m1, :m0)
    Monkey.spawn(:m3, [86, 54, 53], &(&1 + 2), wlf, &(rem(&1, 13) == 0), :m1, :m2)
    Monkey.spawn(:m4, [50, 65, 78, 50, 62, 99], &(&1 + 3), wlf, &(rem(&1, 11) == 0), :m3, :m7)
    Monkey.spawn(:m5, [90], &(&1 + 4), wlf, &(rem(&1, 2) == 0), :m4, :m6)
    Monkey.spawn(:m6, [88, 92, 63, 94, 96, 82, 53, 53], &(&1 + 8), wlf, &(rem(&1, 5) == 0), :m4, :m7)
    Monkey.spawn(:m7, [70, 60, 71, 69, 77, 70, 98], &(&1 * 7), wlf, &(rem(&1, 3) == 0), :m2, :m3)
    [:m0, :m1, :m2, :m3, :m4, :m5, :m6, :m7]
  end

  def test_it() do
    monkeys = Day11Test.monkeys(&(trunc(Float.floor(&1 / 3))))
    inspect_list = do_rounds(monkeys, 1, 20)

    10605 = inspect_list
                      |> Enum.sort
                      |> Enum.take(-2)
                      |> Enum.reduce(fn x, acc -> x * acc end)

    monkeys = Day11Test.monkeys(&(rem(&1, 96577)))
    inspect_list = do_rounds(monkeys, 1, 10000)

    2713310158 = inspect_list
            |> Enum.sort
            |> Enum.take(-2)
            |> Enum.reduce(fn x, acc -> x * acc end)
  end

end

defmodule Day11Test do

  def monkeys(wlf) do
    Monkey.spawn(:mt0, [79, 98], &(&1 * 19), wlf, &(rem(&1, 23) == 0), :mt2, :mt3)
    Monkey.spawn(:mt1, [54, 65, 75, 74], &(&1 + 6), wlf, &(rem(&1, 19) == 0), :mt2, :mt0)
    Monkey.spawn(:mt2, [79, 60, 97], &(&1 * &1), wlf, &(rem(&1, 13) == 0), :mt1, :mt3)
    Monkey.spawn(:mt3, [74], &(&1 + 3), wlf, &(rem(&1, 17) == 0), :mt0, :mt1)
    [:mt0, :mt1, :mt2, :mt3]
  end

end

IO.puts "Day 11"
Day11.test_it()
Day11.part1()
Day11.part2()