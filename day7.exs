defmodule Day7 do

  def part1() do
    input = File.read!("res/day7.txt") |> String.split("\n", trim: true)
    {_, _, result} = walk_dirs(input, 0, [])
    res = result
            |> Enum.filter(fn size -> size <= 100000 end)
            |> Enum.sum
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day7.txt") |> String.split("\n", trim: true)
    {_, _, result} = walk_dirs(input, 0, [])
    used_space = result |> Enum.max
    unused_space = 70000000 - used_space
    req_space = 30000000 - unused_space
    res = result
               |> Enum.filter(fn size -> size >= req_space end)
               |> Enum.min
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def walk_dirs([], curr_size, dirs) do
    new_dirs = [curr_size | dirs]
    {[], curr_size, new_dirs}
  end
  def walk_dirs([input | rest], curr_size, dirs) when input == "$ cd /" do
    walk_dirs(rest, curr_size, dirs)
  end
  def walk_dirs([input | rest], curr_size, dirs) when input == "$ ls" do
    walk_dirs(rest, curr_size, dirs)
  end
  def walk_dirs([input | rest], curr_size, dirs) when input == "$ cd .." do
    new_dirs = [curr_size | dirs]
    {rest, curr_size, new_dirs}
  end
  def walk_dirs([input | rest], curr_size, dirs) do
    cond do
      input =~ ~r/\$ cd \w+/ ->
        {new_input, new_size, new_dirs} = walk_dirs(rest, 0, dirs)
        walk_dirs(new_input, curr_size + new_size, new_dirs)
      input =~ ~r/dir \w+/ ->
        walk_dirs(rest, curr_size, dirs)
      true ->
        [_, file_size] = Regex.run(~r/(\d+) \w+/, input)
        walk_dirs(rest, curr_size + String.to_integer(file_size), dirs)
    end
  end

  def test_it() do
    input = [
      "$ cd /",
      "$ ls",
      "dir a",
      "14848514 b.txt",
      "8504156 c.dat",
      "dir d",
      "$ cd a",
      "$ ls",
      "dir e",
      "29116 f",
      "2557 g",
      "62596 h.lst",
      "$ cd e",
      "$ ls",
      "584 i",
      "$ cd ..",
      "$ cd ..",
      "$ cd d",
      "$ ls",
      "4060174 j",
      "8033020 d.log",
      "5626152 d.ext",
      "7214296 k"
    ]
    {_, _, result} = walk_dirs(input, 0, [])
    #IO.inspect result
    95437 = result
    |> Enum.filter(fn size -> size <= 100000 end)
    |> Enum.sum

    used_space = result |> Enum.max
    48381165 = used_space
    unused_space = 70000000 - used_space
    21618835 = unused_space
    req_space = 30000000 - unused_space
    8381165 = req_space
    24933642 = result
    |> Enum.filter(fn size -> size >= req_space end)
    |> Enum.min
  end

end

IO.puts "Day 7"
Day7.test_it()
Day7.part1()
Day7.part2()