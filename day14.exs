defmodule Cave do

  defstruct [cave: %{}, min_x: 100000, max_x: -100000, max_y: 0]

  def new() do
    %Cave{}
  end

  def fill_with_sand(cave) do
    fill_with_sand(cave, 0)
  end

  def fill_with_sand(cave, sand_units) do
    case pour_sand(cave) do
      {:lands, new_cave} -> fill_with_sand(new_cave, sand_units + 1)
      {_, new_cave} -> {new_cave, sand_units}
    end
  end

  def pour_sand(cave) do
    if Map.has_key?(cave.cave, {500, 0}) do
      {:cave_full, cave}
    else
      pour_sand(cave, 500, 0)
    end
  end

  defp pour_sand(%Cave{max_y: max_y} = cave, _x, y) when y > max_y do
    {:fall_outside, cave}
  end

  defp pour_sand(cave, x, y) do
    # falls down one step if possible
    if Map.has_key?(cave.cave, {x, y + 1}) do
      # move diagonally one step down and to the left
      if Map.has_key?(cave.cave, {x - 1, y + 1}) do
        # move diagonally one step down and to the right
        if Map.has_key?(cave.cave, {x + 1, y + 1}) do
          new_cave = Map.put(cave.cave, {x, y}, "o")
          {:lands, %Cave{cave | cave: new_cave}}
        else
          pour_sand(cave, x + 1 , y + 1)
        end
      else
        pour_sand(cave, x - 1 , y + 1)
      end
    else
      pour_sand(cave, x, y + 1)
    end
  end

  def put_floor(cave) do
    y_max = cave.max_y + 2
    x_min = 500 - y_max - 1
    x_max = 500 + y_max + 1
    put_rocks(cave, {x_min, y_max}, {x_max, y_max})
  end

  def put_rocks(cave, {bx, by} = point, {ex, ey}) when bx == ex and by == ey do
    put_rock(cave, point)
  end

  def put_rocks(cave, {bx, by} = point, {ex, ey} = end_point) do
    new_cave = put_rock(cave, point)
    nx = pp(bx, ex)
    ny = pp(by, ey)
    put_rocks(new_cave, {nx, ny}, end_point)
  end

  defp pp(i1, i2) when i1 < i2 do i1 + 1 end
  defp pp(i1, i2) when i1 > i2 do i1 - 1 end
  defp pp(i1, i2) when i1 == i2 do i1 end

  defp put_rock(cave, {x, y} = point) do
    x_min = min(x, cave.min_x)
    x_max = max(x, cave.max_x)
    y_max = max(y, cave.max_y)
    new_cave = Map.put(cave.cave, point, "#")
    %Cave{cave: new_cave, min_x: x_min, max_x: x_max, max_y: y_max}
  end

  def print(cave) do
    print(cave, cave.min_x, 0)
  end

  defp print(%Cave{min_x: min_x, max_x: max_x} = cave, curr_x, curr_y) when curr_x > max_x do
    IO.puts("")
    print(cave, min_x, curr_y + 1)
  end
  defp print(%Cave{max_y: max_y} = cave, _curr_x, curr_y) when curr_y > max_y do
    cave
  end
  defp print(cave, curr_x, curr_y) do
    IO.write element_at(cave, {curr_x, curr_y})
    print(cave, curr_x + 1, curr_y)
  end

  def element_at(cave, point) do
    if Map.has_key?(cave.cave, point) do
      Map.get(cave.cave, point)
    else
      "."
    end
  end

end

defmodule CaveScanner do

  def scan(input) do
    cave = Cave.new()
    parse(input, cave)
  end

  defp parse([], cave) do cave end
  defp parse([line | rest], cave) do
    new_cave = parse_line(line, cave)
    parse(rest, new_cave)
  end

  defp parse_line(line, cave) do
    # 498,4 -> 498,6 -> 496,6
    [first | rest] = String.split(line, "->", trim: true)
                     |> Enum.map(&parse_point/1)
    build_rocks(first, rest, cave)
  end

  defp parse_point(s_point) do
    String.split(s_point, ",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  defp build_rocks(_point, [], cave) do cave end
  defp build_rocks(begin_point, [end_point | rest], cave) do
    new_cave = Cave.put_rocks(cave, begin_point, end_point)
    build_rocks(end_point, rest, new_cave)
  end

end

defmodule Day14 do

  def part1() do
    input = File.read!("res/day14.txt") |> String.split("\n", trim: true)
    cave = CaveScanner.scan(input)
    #Cave.print(cave)
    {_cave, sand_units} = Cave.fill_with_sand(cave)
    #Cave.print(cave)
    res = sand_units
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day14.txt") |> String.split("\n", trim: true)
    cave = CaveScanner.scan(input)
    cave = Cave.put_floor(cave)
    #Cave.print(cave)
    {_cave, sand_units} = Cave.fill_with_sand(cave)
    #Cave.print(cave)
    res = sand_units
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    input = [
      "498,4 -> 498,6 -> 496,6",
      "503,4 -> 502,4 -> 502,9 -> 494,9"
    ]
    cave = CaveScanner.scan(input)
    #IO.inspect cave
    #Cave.print(cave)

    {_cave, sand_units} = Cave.fill_with_sand(cave)
    #IO.puts ["Sand: ", Integer.to_string(sand_units)]
    #Cave.print(cave)
    24 = sand_units

    cave = CaveScanner.scan(input)
    cave = Cave.put_floor(cave)
    #Cave.print(cave)
    {_cave, sand_units} = Cave.fill_with_sand(cave)
    #IO.puts ["Sand: ", Integer.to_string(sand_units)]
    #Cave.print(cave)
    93 = sand_units
  end

end

IO.puts "Day 14"
Day14.test_it()
Day14.part1()
Day14.part2()