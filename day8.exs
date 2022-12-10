# A grid of trees, where every tree has a height.
# The forest is indexed from [0, 0] (row, col), where origin is at the northwest corner.
defmodule Forest do

  defstruct [:trees, :rows, :cols]

  def new(trees, rows, cols) do
    %Forest{trees: trees, rows: rows, cols: cols}
  end

  def num_visible_trees(forest) do
    0..forest.rows-1
    |> Stream.flat_map(fn row -> 0..forest.cols-1 |> Stream.map(fn col -> {row, col} end) end)
    |> Stream.filter(fn point -> is_visible_at?(forest, elem(point, 0), elem(point, 1)) end)
    |> Enum.count
  end

  def height_at(forest, row, col) do
    :binary.decode_unsigned(binary_part(forest.trees, forest.cols * row + col, 1))
  end

  def is_visible_at?(_forest, row, _col) when row == 0 do true end
  def is_visible_at?(_forest, _row, col) when col == 0 do true end
  def is_visible_at?(%Forest{trees: _, rows: rows, cols: _} , row, _col) when row == rows - 1 do true end
  def is_visible_at?(%Forest{trees: _, rows: _, cols: cols}, _row, col) when col == cols - 1 do true end
  def is_visible_at?(forest, row, col) do
    height = height_at(forest, row, col)
    is_all_shorter_than?(forest, height, row - 1, col, -1, 0)
      or is_all_shorter_than?(forest, height, row + 1, col, 1, 0)
      or is_all_shorter_than?(forest, height, row, col + 1, 0, 1)
      or is_all_shorter_than?(forest, height, row, col - 1, 0, -1)
  end

  defp is_all_shorter_than?(_, _, row, _, _, _) when row < 0 do true end
  defp is_all_shorter_than?(_, _, _, col, _, _) when col < 0 do true end
  defp is_all_shorter_than?(%Forest{trees: _, rows: rows, cols: _}, _, row, _, _, _) when row >= rows do true end
  defp is_all_shorter_than?(%Forest{trees: _, rows: _, cols: cols}, _, _, col, _, _) when col >= cols do true end
  defp is_all_shorter_than?(forest, height, row, col, dir_row, dir_col) do
    the_height = height_at(forest, row, col)
    if the_height >= height do
      false
    else
      is_all_shorter_than?(forest, height, row + dir_row, col + dir_col, dir_row, dir_col)
    end
  end

  def max_scenic_score(forest) do
    0..forest.rows-1
    |> Stream.flat_map(fn row -> 0..forest.cols-1 |> Stream.map(fn col -> {row, col} end) end)
    |> Stream.map(fn point -> scenic_score(forest, elem(point, 0), elem(point, 1)) end)
    |> Enum.max
  end

  def scenic_score(forest, row, col) do
    height = height_at(forest, row, col)
    viewing_distance(forest, height, 0, row - 1, col, -1, 0)
    * viewing_distance(forest, height, 0, row + 1, col, 1, 0)
    * viewing_distance(forest, height, 0, row, col + 1, 0, 1)
    * viewing_distance(forest, height, 0, row, col - 1, 0, -1)
  end

  defp viewing_distance(_, _, distance, row, _, _, _) when row < 0 do distance end
  defp viewing_distance(_, _, distance, _, col, _, _) when col < 0 do distance end
  defp viewing_distance(%Forest{trees: _, rows: rows, cols: _}, _, distance, row, _, _, _) when row >= rows do distance end
  defp viewing_distance(%Forest{trees: _, rows: _, cols: cols}, _, distance, _, col, _, _) when col >= cols do distance end
  defp viewing_distance(forest, height, distance, row, col, dir_row, dir_col) do
    the_height = height_at(forest, row, col)
    if the_height >= height do
      distance + 1
    else
      viewing_distance(forest, height, distance + 1, row + dir_row, col + dir_col, dir_row, dir_col)
    end
  end
end

defmodule ForestParser do
  def parse_forest([first|_] = the_list) do
    cols = String.length(first)
    rows = length(the_list)
    trees = parse_lines(the_list)
    Forest.new(trees, rows, cols)
  end

  defp parse_lines(lines) do
    lines
    |> Enum.map(fn line -> parse_line(line) end)
    |> Enum.into(<<>>)
  end

  defp parse_line(line) do
    to_charlist(line)
    |> Enum.map(fn x -> x - 48 end)
    |> Enum.into(<<>>, fn digit -> <<digit::unsigned-integer-size(8)>> end)
  end
end

defmodule Day8 do

  def part1() do
    input = File.read!("res/day8.txt") |> String.split("\n", trim: true)
    forest = ForestParser.parse_forest(input)
    res = Forest.num_visible_trees(forest)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day8.txt") |> String.split("\n", trim: true)
    forest = ForestParser.parse_forest(input)
    res = Forest.max_scenic_score(forest)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    forest = Forest.new(<<1, 2, 3, 4, 5, 6, 7, 8, 9>>, 3, 3)
    1 = Forest.height_at(forest, 0, 0)
    2 = Forest.height_at(forest, 0, 1)
    3 = Forest.height_at(forest, 0, 2)
    4 = Forest.height_at(forest, 1, 0)
    5 = Forest.height_at(forest, 1, 1)
    6 = Forest.height_at(forest, 1, 2)
    7 = Forest.height_at(forest, 2, 0)
    8 = Forest.height_at(forest, 2, 1)
    9 = Forest.height_at(forest, 2, 2)

    true = Forest.is_visible_at?(forest, 0, 0)
    true = Forest.is_visible_at?(forest, 1, 1)

    input = [
      "30373",
      "25512",
      "65332",
      "33549",
      "35390"
    ]
    forest = ForestParser.parse_forest(input)
    3 = Forest.height_at(forest, 0, 0)
    1 = Forest.height_at(forest, 1, 3)
    9 = Forest.height_at(forest, 3, 4)
    true = Forest.is_visible_at?(forest, 1, 2)
    false = Forest.is_visible_at?(forest, 1, 3)
    true = Forest.is_visible_at?(forest, 2, 1)
    false = Forest.is_visible_at?(forest, 2, 2)
    true = Forest.is_visible_at?(forest, 2, 3)
    false = Forest.is_visible_at?(forest, 3, 1)
    true = Forest.is_visible_at?(forest, 3, 2)
    false = Forest.is_visible_at?(forest, 3, 3)
    21 = Forest.num_visible_trees(forest)
    4 = Forest.scenic_score(forest, 1, 2)
    8 = Forest.scenic_score(forest, 3, 2)
    8 = Forest.max_scenic_score(forest)
  end

end

IO.puts "Day 8"
Day8.test_it()
Day8.part1()
Day8.part2()