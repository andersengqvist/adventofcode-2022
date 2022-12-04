defmodule Day1 do

  # Chunks a stream of strings into a stream of lists
  # a new list will be started when an empty string is encountered
  # Note: list will be in reversed order,
  # Example:
  # ["1", "2", "3", "", "4", "", "5", "6"] will be chunked into
  # [["3", "2", "1"], ["4"], ["6", "5"]]
  def chunk_by_empty_line(the_stream) do
    chunk_fun = fn element, acc ->
      if String.length(element) == 0 do
        {:cont, acc, []}
      else
        {:cont, [element | acc]}
      end
    end
    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end
    Stream.chunk_while(the_stream, [], chunk_fun, after_fun)
  end

  def sum_chunk(the_chunk) do
    the_chunk
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum
  end

  def part1_again() do
    res = File.stream!("res/day1.txt")
          |> Stream.map(&String.trim/1)
          #|> Stream.chunk_by(&(String.length(&1) == 0))
          |> chunk_by_empty_line
          |> Stream.map(&sum_chunk/1)
          |> Enum.max
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2_again() do
    res = File.stream!("res/day1.txt")
          |> Stream.map(&String.trim/1)
          |> chunk_by_empty_line
          |> Stream.map(&sum_chunk/1)
          |> Enum.sort
          |> Enum.take(-3)
          |> Enum.sum
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end


  def part1() do
    res = File.read!("res/day1.txt")
          |> String.split("\n\n", trim: true)
          |> Enum.map(&sumStuff/1)
          #|> IO.inspect(label: "before")
          |> Enum.max
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    res = File.read!("res/day1.txt")
          |> String.split("\n\n", trim: true)
          |> Enum.map(&sumStuff/1)
          |> Enum.sort
          #|> IO.inspect(label: "before")
          |> Enum.take(-3)
          |> Enum.sum

    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def sumStuff(stuff) do
    stuff
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

end

# Playing around with both lists and streams

IO.puts "Day 1"
Day1.part1()
Day1.part1_again()
Day1.part2()
Day1.part2_again()