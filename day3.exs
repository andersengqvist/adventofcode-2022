defmodule Day3 do

  def part1() do
    res = File.stream!("res/day3.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.map(&find_priority_of_item_in_both_compartments/1)
          |> Enum.sum
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def find_priority_of_item_in_both_compartments(rucksack) do
    {first, second} = String.split_at(rucksack, div(String.length(rucksack), 2))

    to_charlist(first)
      |> Enum.filter(fn x -> String.contains?(second, to_string([x])) end)
      |> Enum.uniq
      |> Enum.map(&priority/1)
      |> Enum.sum
  end

  def part2() do
    res = File.stream!("res/day3.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.chunk_every(3)
          |> Stream.map(&find_priority_of_item_in_group/1)
          |> Enum.sum
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def find_priority_of_item_in_group(group) do
    [first, second, third] = group
    to_charlist(first)
    |> Enum.filter(fn x -> String.contains?(second, to_string([x])) and String.contains?(third, to_string([x])) end)
    |> Enum.uniq
    |> Enum.map(&priority/1)
    |> Enum.sum
  end

  # Lowercase item types a through z have priorities 1 through 26.
  # Uppercase item types A through Z have priorities 27 through 52.
  def priority(item) when item >= 97 and item <= 122 do
    item - 97 + 1
  end
  def priority(item) when item >= 65 and item <= 90 do
    item - 65 + 27
  end

end

IO.puts "Day 3"
Day3.part1()
Day3.part2()