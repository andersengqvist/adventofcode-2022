defmodule Compare do

  #If both values are integers, the lower integer should come first.
  # If the left integer is lower than the right integer, the inputs are in the right order.
  # If the left integer is higher than the right integer, the inputs are not in the right order.
  # Otherwise, the inputs are the same integer; continue checking the next part of the input.
  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> {:right_order}
      left > right -> {:not_right_order}
      true -> {:continue_comparing}
    end
  end

  # If both values are lists, compare the first value of each list, then the second value, and so on.
  def compare([left | left_rest], [right | right_rest]) do
    case compare(left, right) do
      {:continue_comparing} -> compare(left_rest, right_rest)
      done -> done
    end
  end
  # If the left list runs out of items first, the inputs are in the right order.
  def compare([], [_|_]) do
    {:right_order}
  end
  # If the right list runs out of items first, the inputs are not in the right order.
  def compare([_|_], []) do
    {:not_right_order}
  end
  # If the lists are the same length and no comparison makes a decision about the order,
  # continue checking the next part of the input.
  def compare([], []) do
    {:continue_comparing}
  end

  #If exactly one value is an integer, convert the integer to a list which contains that integer as its only value,
  # then retry the comparison.
  # For example, if comparing [0,0,0] and 2, convert the right value to [2] (a list containing 2);
  # the result is then found by instead comparing [0,0,0] and [2].
  def compare(left, right) when is_list(left) and is_integer(right) do
    compare(left, [right])
  end
  def compare(left, right) when is_integer(left) and is_list(right) do
    compare([left], right)
  end

end

defmodule Part1 do

  def parse_input() do
    File.read!("res/day13.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_packet_pair/1)
  end

  def parse_packet_pair(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse_packet/1)
    |> List.to_tuple
  end

  def parse_packet(input) do
    {res, _} = Code.eval_string(input)
    res
  end

  def sum_indices_in_right_order([], _idx, sum) do
    sum
  end
  def sum_indices_in_right_order([{left, right} | rest], idx, sum) do
    case Compare.compare(left, right) do
      {:right_order} -> sum_indices_in_right_order(rest, idx + 1, sum + idx)
      {:not_right_order} -> sum_indices_in_right_order(rest, idx + 1, sum)
    end
  end
end

defmodule Part2 do

  def parse_input() do
    File.read!("res/day13.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.flat_map(&parse_packet_pair/1)
  end

  def parse_packet_pair(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse_packet/1)
  end

  def parse_packet(input) do
    {res, _} = Code.eval_string(input)
    res
  end

  def sort_fun(left, right) do
    case Compare.compare(left, right) do
      {:right_order} -> true
      _ -> false
    end
  end

  def decoder_key([], _idx, prod) do
    prod
  end
  def decoder_key([head | rest], idx, prod) do
    case head do
      [[2]] -> decoder_key(rest, idx + 1, prod * idx)
      [[6]] -> decoder_key(rest, idx + 1, prod * idx)
      _ -> decoder_key(rest, idx + 1, prod)
    end
  end
end

defmodule Day13 do

  def part1() do
    packet_pairs = Part1.parse_input()
    res = Part1.sum_indices_in_right_order(packet_pairs, 1, 0)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    packets = [[[2]], [[6]]] ++ Part2.parse_input()
    sorted = Enum.sort(packets, &Part2.sort_fun/2)
    res = Part2.decoder_key(sorted, 1, 1)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    {:right_order} = Compare.compare([1,1,3,1,1], [1,1,5,1,1])
    {:right_order} = Compare.compare([[1],[2,3,4]], [[1],4])
    {:not_right_order} = Compare.compare([9], [[8,7,6]])
    {:right_order} = Compare.compare([[4,4],4,4], [[4,4],4,4,4])
    {:not_right_order} = Compare.compare([7,7,7,7], [7,7,7])
    {:right_order} = Compare.compare([], [3])
    {:not_right_order} = Compare.compare([[[]]], [[]])
    {:not_right_order} = Compare.compare([1,[2,[3,[4,[5,6,7]]]],8,9], [1,[2,[3,[4,[5,6,0]]]],8,9])

    packet_pairs = [
      {[1,1,3,1,1], [1,1,5,1,1]},
      {[[1],[2,3,4]], [[1],4]},
      {[9], [[8,7,6]]},
      {[[4,4],4,4], [[4,4],4,4,4]},
      {[7,7,7,7], [7,7,7]},
      {[], [3]},
      {[[[]]], [[]]},
      {[1,[2,[3,[4,[5,6,7]]]],8,9], [1,[2,[3,[4,[5,6,0]]]],8,9]}
    ]
    13 = Part1.sum_indices_in_right_order(packet_pairs, 1, 0)

    packets = [
      [1,1,3,1,1],
      [1,1,5,1,1],
      [[1],[2,3,4]],
      [[1],4],
      [9],
      [[8,7,6]],
      [[4,4],4,4],
      [[4,4],4,4,4],
      [7,7,7,7],
      [7,7,7],
      [],
      [3],
      [[[]]],
      [[]],
      [1,[2,[3,[4,[5,6,7]]]],8,9],
      [1,[2,[3,[4,[5,6,0]]]],8,9],
      [[2]],
      [[6]]
    ]
    sorted = Enum.sort(packets, &Part2.sort_fun/2)
    140 = Part2.decoder_key(sorted, 1, 1)
  end

end

IO.puts "Day 13"
Day13.test_it()
Day13.part1()
Day13.part2()