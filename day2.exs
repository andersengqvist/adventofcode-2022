defmodule Day2 do

  def part1() do
    res = File.stream!("res/day2.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.map(&round_1_point/1)
          |> Enum.sum
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    res = File.stream!("res/day2.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.map(&round_2_point/1)
          |> Enum.sum
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  # outcome of the round
  # (0 if you lost, 3 if the round was a draw, and 6 if you won) +
  # (1 for Rock, 2 for Paper, and 3 for Scissors)
  # A for Rock, B for Paper, and C for Scissors
  def round_1_point("A X") do 3 + 1 end
  def round_1_point("A Y") do 6 + 2 end
  def round_1_point("A Z") do 0 + 3 end
  def round_1_point("B X") do 0 + 1 end
  def round_1_point("B Y") do 3 + 2 end
  def round_1_point("B Z") do 6 + 3 end
  def round_1_point("C X") do 6 + 1 end
  def round_1_point("C Y") do 0 + 2 end
  def round_1_point("C Z") do 3 + 3 end

  # X means you need to lose
  # Y means you need to end the round in a draw
  # Z means you need to win. Good luck!"
  # A for Rock, B for Paper, and C for Scissors
  # (0 if you lost, 3 if the round was a draw, and 6 if you won) +
  # (1 for Rock, 2 for Paper, and 3 for Scissors)
  def round_2_point("A X") do 0 + 3 end # scissors
  def round_2_point("A Y") do 3 + 1 end # rock
  def round_2_point("A Z") do 6 + 2 end # paper
  def round_2_point("B X") do 0 + 1 end # rock
  def round_2_point("B Y") do 3 + 2 end # paper
  def round_2_point("B Z") do 6 + 3 end # scissors
  def round_2_point("C X") do 0 + 2 end # paper
  def round_2_point("C Y") do 3 + 3 end # scissors
  def round_2_point("C Z") do 6 + 1 end # rock
end

IO.puts "Day 2"
Day2.part1()
Day2.part2()