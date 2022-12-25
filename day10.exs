defmodule Register do

  def new() do
    1
  end

  def add(amount) do
    fn register -> amount + register end
  end

  def no_op() do
    fn register -> register end
  end
end

defmodule Cpu do

  def run_instructions([], register, _fun, stuff, _cycle) do
    {register, stuff}
  end
  def run_instructions([instruction | rest], register, fun, stuff, cycle) when instruction == "noop" do
    {new_register, new_stuff, new_cycle} = run_instruction(register, Register.no_op(), fun, stuff, cycle, 1)
    run_instructions(rest, new_register, fun, new_stuff, new_cycle)
  end

  def run_instructions([instruction | rest], register, fun, stuff, cycle) do
    [_, adder] = Regex.run(~r/addx (-?\d+)/, instruction)
    {new_register, new_stuff, new_cycle} = run_instruction(register, Register.add(String.to_integer(adder)), fun, stuff, cycle, 2)
    run_instructions(rest, new_register, fun, new_stuff, new_cycle)
  end

  def run_instruction(register, reg_updater, _fun, stuff, cycle, tick) when tick < 1 do
    new_register = reg_updater.(register)
    {new_register, stuff, cycle}
  end
  def run_instruction(register, reg_updater, fun, stuff, cycle, tick) do
    new_stuff = fun.(register, stuff, cycle)
    run_instruction(register, reg_updater, fun, new_stuff, cycle + 1, tick - 1)
  end
end

defmodule Crt do
  defstruct [x: 0, y: 0, lit_pixels: MapSet.new()]

  def new() do
    %Crt{}
  end

  def crt_probe(register, crt, _cycle) do
    draw(crt, register)
  end

  def draw(crt = %Crt{x: x}, register) when register >= x - 1 and register <= x + 1 do
    pix = MapSet.put(crt.lit_pixels, {crt.x, crt.y})
    tick(crt.x, crt.y, pix)
  end

  def draw(crt = %Crt{x: x}, register) when register < x - 1 or register > x + 1 do
    tick(crt.x, crt.y, crt.lit_pixels)
  end

  def tick(x, y, pix) when x >= 39 do
    %Crt{x: 0, y: y + 1, lit_pixels: pix}
  end

  def tick(x, y, pix) when x < 39 do
    %Crt{x: x + 1, y: y, lit_pixels: pix}
  end

  def print(crt) do
    Enum.each(0..crt.y-1, fn y ->
      Enum.each(0..39, fn x ->
        if MapSet.member?(crt.lit_pixels, {x, y}) do
          IO.write("#")
        else
          IO.write(".")
        end
      end)
      IO.puts("")
    end)
  end
end

defmodule Day10 do

  def part1() do
    instructions = File.read!("res/day10.txt") |> String.split("\n", trim: true)
    # during the 20th, 60th, 100th, 140th, 180th, and 220th cycles).
    probe = signal_strength_probe(MapSet.new([20, 60, 100, 140, 180, 220]))
    {_, total_signal_strenght} = Cpu.run_instructions(instructions, Register.new(), probe, 0, 1)
    res = total_signal_strenght
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    instructions = File.read!("res/day10.txt") |> String.split("\n", trim: true)
    {_, crt} = Cpu.run_instructions(instructions, Register.new(), &Crt.crt_probe/3, Crt.new(), 1)
    IO.puts "Part 2:"
    Crt.print(crt)
  end

  def print_fun(register, stuff, cycle) do
    #IO.puts ["Register ", Integer.to_string(register), ", stuff: ", Integer.to_string(stuff), ", cycle: ", Integer.to_string(cycle)]
    stuff
  end

  def signal_strength_probe(cycles_to_probe) do
    fn (register, stuff, cycle) ->
      if MapSet.member?(cycles_to_probe, cycle) do
        stuff + register * cycle
      else
        stuff
      end
    end
  end

  def test_it() do
    instructions = [
      "noop",
      "addx 3",
      "addx -5"
    ]
    {register, _} = Cpu.run_instructions(instructions, Register.new(), &print_fun/3, 9, 1)
    -1 = register

    instructions = File.read!("res/day10_test.txt") |> String.split("\n", trim: true)
    # during the 20th, 60th, 100th, 140th, 180th, and 220th cycles).
    probe = signal_strength_probe(MapSet.new([20, 60, 100, 140, 180, 220]))
    {_, total_signal_strenght} = Cpu.run_instructions(instructions, Register.new(), probe, 0, 1)
    13140 = total_signal_strenght

    {_, crt} = Cpu.run_instructions(instructions, Register.new(), &Crt.crt_probe/3, Crt.new(), 1)
    Crt.print(crt)
  end

end

IO.puts "Day 10"
Day10.test_it()
Day10.part1()
Day10.part2()