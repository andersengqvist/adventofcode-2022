# A peculiar data structure.
# You can add items to it, up until max_size is reached,
# Then the oldest item is removed, FIFO style.
# Oh, and it also counts the number of unique elements it contains
# I believe this will be handy for everyday use
# In lack of better name I call the data structure Something.
defmodule Something do

  defstruct [:max_size, queue: :queue.new, size: 0, num_uniq: 0]

  def new(max_size) when max_size > 0 do
    %Something{max_size: max_size}
  end

  # Pushes elem, removing the oldest if size == max_size
  # returns the new Something
  def push(something, elem) do
    {queue, size, num_uniq} = if something.size == something.max_size do
      # remove oldest value
      {{:value, removed}, new_queue} = :queue.out(something.queue)
      # Decrease number of unique elements if that was the only elem with that value
      num_uniq = dec_if_uniq(new_queue, removed, something.num_uniq)
      {new_queue, something.size, num_uniq}
    else
      # Do not remove the oldest value, increase size by 1
      {something.queue, something.size + 1, something.num_uniq}
    end
    # Increase number of unique elements if the new element is not present
    num_uniq = inc_if_uniq(queue, elem, num_uniq)
    %Something{
      max_size: something.max_size,
      queue: :queue.in(elem, queue),
      size: size,
      num_uniq: num_uniq
    }
  end

  # Returns true if max size is reached and all elements are unique
  def all_unique?(something) do
    something.size == something.max_size and something.num_uniq == something.size
  end

  defp inc_if_uniq(queue, elem, num_uniq) do
    if :queue.member(elem, queue) do
      num_uniq
    else
      num_uniq + 1
    end
  end

  defp dec_if_uniq(queue, elem, num_uniq) do
    if :queue.member(elem, queue) do
      num_uniq
    else
      num_uniq - 1
    end
  end

end

defmodule Day6 do

  def part1() do
    datastream = File.read!("res/day6.txt")
    res = first_marker(to_charlist(datastream), 4)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    datastream = File.read!("res/day6.txt")
    res = first_marker(to_charlist(datastream), 14)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def first_marker(list, num_distinct) do
    first_marker(Something.new(num_distinct), list, 0)
  end

  def first_marker(something, list, pos) do
    if Something.all_unique?(something) do
      pos
    else
      add_marker(something, list, pos)
    end
  end

  def add_marker(_something, [], _pos) do
    -1
  end

  def add_marker(something, [head | tail], pos) do
    first_marker(Something.push(something, head), tail, pos + 1)
  end

  def test_it() do
    -1 = first_marker([1, 2, 3], 4)
    -1 = first_marker([1, 2, 3, 1, 2, 3], 4)
    4 = first_marker([1, 2, 3, 4], 4)

    7 = first_marker(to_charlist("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 4)
    5 = first_marker(to_charlist("bvwbjplbgvbhsrlpgdmjqwftvncz"), 4)
    6 = first_marker(to_charlist("nppdvjthqldpwncqszvftbrmjlhg"), 4)
    10 = first_marker(to_charlist("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 4)
    11 = first_marker(to_charlist("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 4)

    19 = first_marker(to_charlist("mjqjpqmgbljsphdztnvjfqwrcgsmlb"), 14)
    23 = first_marker(to_charlist("bvwbjplbgvbhsrlpgdmjqwftvncz"), 14)
    23 = first_marker(to_charlist("nppdvjthqldpwncqszvftbrmjlhg"), 14)
    29 = first_marker(to_charlist("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), 14)
    26 = first_marker(to_charlist("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), 14)
  end

end

IO.puts "Day 6"
Day6.test_it()
Day6.part1()
Day6.part2()