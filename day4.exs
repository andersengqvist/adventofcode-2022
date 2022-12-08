defmodule Day4 do

  def part1() do
    res = File.stream!("res/day4.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.map(&parse_pair/1)
          |> Stream.filter(&pair_fully_contains?/1)
          |> Enum.count
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    res = File.stream!("res/day4.txt")
          |> Stream.map(&String.trim/1)
          |> Stream.map(&parse_pair/1)
          |> Stream.filter(&pair_overlaps?/1)
          |> Enum.count
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def parse_pair(the_str) do
    [str1, str2] = String.split(the_str, ",", trim: true)
    {parse_assignment(str1), parse_assignment(str2)}
  end

  def parse_assignment(the_str) do
    [str1, str2] = String.split(the_str, "-", trim: true)
    {String.to_integer(str1), String.to_integer(str2)}
  end

  def pair_fully_contains?({pair1, pair2}) do
    fully_contains?(pair1, pair2) or fully_contains?(pair2, pair1)
  end

  def fully_contains?({s11, s12}, {s21, s22}) do
    s11 <= s21 and s12 >= s22
  end

  def pair_overlaps?({pair1, pair2}) do
    not (is_below?(pair1, pair2) or is_below?(pair2, pair1))
  end

  def is_below?({_s11, s12}, {s21, _s22}) do
    s12 < s21
  end

  def test_it() do
    true = pair_fully_contains?({{2, 8}, {3, 7}})
    true = pair_fully_contains?({{6, 6}, {4, 6}})
    false = pair_overlaps?({{2, 4}, {6, 8}})
    false = pair_overlaps?({{2, 3}, {4, 5}})
    true = pair_overlaps?({{5, 7}, {7, 9}})
    true = pair_overlaps?({{7, 9}, {5, 7}})
    true = pair_overlaps?({{2, 8}, {3, 7}})
    true = pair_overlaps?({{6, 6}, {4, 6}})
    true = pair_overlaps?({{2, 6}, {4, 8}})
  end

end

IO.puts "Day 4"
Day4.test_it()
Day4.part1()
Day4.part2()