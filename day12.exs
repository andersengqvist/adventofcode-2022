Code.require_file("graph.exs", "./lib")

defmodule HeightMap do

  defstruct [:heights, :rows, :cols]

  def new(heights, rows, cols) do
    %HeightMap{heights: heights, rows: rows, cols: cols}
  end

  def height_at(height_map, {row, col}) do
    :binary.decode_unsigned(binary_part(height_map.heights, height_map.cols * row + col, 1))
  end
end

defmodule HeightMapUp do
  @behaviour Graph

  def neighbours(height_map, {row, col} = pos) do
    max_climb = HeightMap.height_at(height_map, pos) + 1
    [{row, col - 1}, {row, col + 1}, {row - 1, col}, {row + 1, col}]
    |> Enum.flat_map(fn pos -> neighbour_at(height_map, max_climb, pos) end)
  end

  defp neighbour_at(_height_map, _max_climb, {row, _col}) when row < 0 do [] end
  defp neighbour_at(_height_map, _max_climb, {_row, col}) when col < 0 do [] end
  defp neighbour_at(%HeightMap{rows: rows}, _max_climb, {row, _col}) when row >= rows do [] end
  defp neighbour_at(%HeightMap{cols: cols}, _max_climb, {_row, col}) when col >= cols do [] end
  defp neighbour_at(height_map, max_climb, pos) do
    height = HeightMap.height_at(height_map, pos)
    if max_climb >= height do
      [pos]
    else
      []
    end
  end

end

defmodule HeightMapDown do
  @behaviour Graph

  def neighbours(height_map, {row, col} = pos) do
    min_height = HeightMap.height_at(height_map, pos) - 1
    [{row, col - 1}, {row, col + 1}, {row - 1, col}, {row + 1, col}]
    |> Enum.flat_map(fn pos -> neighbour_at(height_map, min_height, pos) end)
  end

  defp neighbour_at(_height_map, _min_height, {row, _col}) when row < 0 do [] end
  defp neighbour_at(_height_map, _min_height, {_row, col}) when col < 0 do [] end
  defp neighbour_at(%HeightMap{rows: rows}, _min_height, {row, _col}) when row >= rows do [] end
  defp neighbour_at(%HeightMap{cols: cols}, _min_height, {_row, col}) when col >= cols do [] end
  defp neighbour_at(height_map, min_height, pos) do
    height = HeightMap.height_at(height_map, pos)
    if height >= min_height do
      [pos]
    else
      []
    end
  end

end

defmodule HeightMapParser do
  def parse_height_map([first|_] = the_list) do
    cols = String.length(first)
    rows = length(the_list)
    height_map = parse_lines(the_list)
    start_pos = find_stuff(the_list, 0, 83)
    goal_pos = find_stuff(the_list, 0, 69)
    {HeightMap.new(height_map, rows, cols), start_pos, goal_pos}
  end

  defp parse_lines(lines) do
    lines
    |> Enum.map(fn line -> parse_line(line) end)
    |> Enum.into(<<>>)
  end

  defp parse_line(line) do
    to_charlist(line)
    |> Enum.map(&(parse_height(&1)))
    |> Enum.into(<<>>, fn digit -> <<digit::unsigned-integer-size(8)>> end)
  end

  defp parse_height(x) do
    case x do
      83 -> 0  # S elevation a
      69 -> 25 # E elevation z
      elevation -> elevation - 97
    end
  end

  defp find_stuff([line | rest], row, stuff) do
    case find_in_line(to_charlist(line), 0, stuff) do
      {:found, col} -> {row, col}
      {:not_found} -> find_stuff(rest, row + 1, stuff)
    end
  end
  defp find_in_line([], _col, _stuff) do {:not_found} end
  defp find_in_line([thing | rest], col, stuff) do
    if thing == stuff do
      {:found, col}
    else
      find_in_line(rest, col + 1, stuff)
    end
  end
end

defmodule Day12 do

  def part1() do
    input = File.read!("res/day12.txt") |> String.split("\n", trim: true)
    {height_map, start_pos, goal_pos} = HeightMapParser.parse_height_map(input)
    {:found, _, path} = Graph.Search.bfs(HeightMapUp, height_map, start_pos, fn _, n -> n == goal_pos end)
    res = length(path) - 1
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day12.txt") |> String.split("\n", trim: true)
    {height_map, _, start_pos} = HeightMapParser.parse_height_map(input)
    {:found, _, path} = Graph.Search.bfs(HeightMapDown, height_map, start_pos, fn g, n -> HeightMap.height_at(g, n) == 0 end)
    res = length(path) - 1
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    input = [
      "Sabqponm",
      "abcryxxl",
      "accszExk",
      "acctuvwj",
      "abdefghi"
    ]
    {height_map, start_pos, goal_pos} = HeightMapParser.parse_height_map(input)

    {:found, _, path} = Graph.Search.bfs(HeightMapUp, height_map, start_pos, fn _, n -> n == goal_pos end)
    31 = length(path) - 1

    {:found, _, path} = Graph.Search.bfs(HeightMapDown, height_map, goal_pos, fn g, n -> HeightMap.height_at(g, n) == 0 end)
    29 = length(path) - 1
  end

end

IO.puts "Day 12"
Day12.test_it()
Day12.part1()
Day12.part2()