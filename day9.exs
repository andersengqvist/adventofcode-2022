defmodule Point do
  defstruct [:x, :y]

  def new(x, y) do
    %Point{x: x, y: y}
  end

end

defmodule Rope do

  def make_knots(num_knots) do
    1..num_knots |> Enum.map(fn _ -> Point.new(0, 0) end)
  end

  def motions([], knots, visited) do
    {knots, visited}
  end
  def motions([motion | rest], knots, visited) do
    [_, direction, times] = Regex.run(~r/(\w) (\d+)/, motion)
    {new_knots, new_visited} = move(knots, find_direction(direction), String.to_integer(times), visited)
    motions(rest, new_knots, new_visited)
  end

  def find_direction(dir) when dir == "U" do  Point.new(0, 1) end
  def find_direction(dir) when dir == "D" do  Point.new(0, -1) end
  def find_direction(dir) when dir == "R" do  Point.new(1, 0) end
  def find_direction(dir) when dir == "L" do  Point.new(-1, 0) end

  def move(knots, _direction, times, visited) when times < 1 do
    {knots, visited}
  end
  def move([head | rest], direction, times, visited) do
    new_head = Point.new(head.x + direction.x, head.y + direction.y)
    {knots_reversed, new_visited} = follow(rest, [new_head], visited)
    new_knots = Enum.reverse(knots_reversed)
    move(new_knots, direction, times - 1, new_visited)
  end

  def follow([tail], [head | _] = acc, visited) do
    new_tail = follow(tail, head)
    new_visited = MapSet.put(visited, new_tail)
    new_acc = [new_tail | acc]
    {new_acc, new_visited}
  end
  def follow([tail | rest], [head | _] = acc, visited) do
    new_tail = follow(tail, head)
    new_acc = [new_tail | acc]
    follow(rest, new_acc, visited)
  end

  def follow(%Point{x: tx, y: ty} = tail, %Point{x: hx, y: hy}) when tx >= hx - 1 and tx <= hx + 1 and ty >= hy - 1 and ty <= hy + 1 do
    tail
  end

  # nothing to do with lists
  def follow(tail, head) do
    new_x = follow_2d(tail.x, head.x)
    new_y = follow_2d(tail.y, head.y)
    Point.new(new_x, new_y)
  end

  defp follow_2d(tail, head) do
    cond do
      tail < head ->
        tail + 1
      tail > head ->
        tail - 1
      true ->
        tail
    end
  end
end

defmodule Day9 do

  def part1() do
    instructions = File.read!("res/day9.txt") |> String.split("\n", trim: true)
    {_knots, visited} = Rope.motions(instructions, Rope.make_knots(2), MapSet.new())
    res = MapSet.size(visited)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    instructions = File.read!("res/day9.txt") |> String.split("\n", trim: true)
    {_knots, visited} = Rope.motions(instructions, Rope.make_knots(10), MapSet.new())
    res = MapSet.size(visited)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    %Point{x: 1, y: 1} = Rope.follow(Point.new(1, 1), Point.new(1, 1))
    %Point{x: 1, y: 1} = Rope.follow(Point.new(1, 1), Point.new(2, 1))
    %Point{x: 1, y: 1} = Rope.follow(Point.new(1, 1), Point.new(1, 2))
    %Point{x: 1, y: 1} = Rope.follow(Point.new(1, 1), Point.new(2, 2))
    %Point{x: 1, y: 2} = Rope.follow(Point.new(1, 1), Point.new(1, 3))
    %Point{x: 2, y: 1} = Rope.follow(Point.new(1, 1), Point.new(3, 1))
    %Point{x: 2, y: 2} = Rope.follow(Point.new(1, 1), Point.new(2, 3))
    %Point{x: 2, y: 2} = Rope.follow(Point.new(1, 1), Point.new(3, 2))

    [%Point{x: 0, y: 0}] = Rope.make_knots(1)
    [%Point{x: 0, y: 0}, %Point{x: 0, y: 0}] = Rope.make_knots(2)

    instructions = [
      "R 4",
      "U 4",
      "L 3",
      "D 1",
      "R 4",
      "D 1",
      "L 5",
      "R 2"
    ]
    {[head, tail], visited} = Rope.motions(instructions, Rope.make_knots(2), MapSet.new())
    %Point{x: 2, y: 2} = head
    %Point{x: 1, y: 2} = tail
    13 = MapSet.size(visited)

    {[head, t1, t2, t3, t4, t5 | _rest], visited} = Rope.motions(instructions, Rope.make_knots(10), MapSet.new())
    %Point{x: 2, y: 2} = head
    %Point{x: 1, y: 2} = t1
    %Point{x: 2, y: 2} = t2
    %Point{x: 3, y: 2} = t3
    %Point{x: 2, y: 2} = t4
    %Point{x: 1, y: 1} = t5
    1 = MapSet.size(visited)

    instructions = [
      "R 5",
      "U 8",
      "L 8",
      "D 3",
      "R 17",
      "D 10",
      "L 25",
      "U 20"
    ]
    {[head | _rest], visited} = Rope.motions(instructions, Rope.make_knots(10), MapSet.new())
    %Point{x: -11, y: 15} = head
    36 = MapSet.size(visited)
  end

end

IO.puts "Day 9"
Day9.test_it()
Day9.part1()
Day9.part2()