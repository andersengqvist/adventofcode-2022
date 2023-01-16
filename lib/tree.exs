defmodule MaxGameTree do

  @type world :: any()
  @type action :: any()
  @type state :: any()
  @type score :: number()

  @callback actions(world, state) :: [{action, score}]

  @callback apply_action(world, state, action) :: state

  defmodule Search do

    def max(module, world, init_state, max_actions) do
      options = module.actions(world, init_state)
                |> Enum.map(fn {action, score} -> max(module, world, init_state, action, score, 1, max_actions) end)
                |> Enum.sort(fn {p1, _}, {p2, _} -> p1 >= p2 end)
                #|> IO.inspect # TODO - remove

      case options do
        [] -> {0, []}
        [winner | _] -> winner
      end
    end

    # Returns {total_score, [action]}
    defp max(_module, _world, _state, action, points, depth, max_depth) when depth >= max_depth do
      {points, [action]}
    end
    defp max(module, world, state, action, points, depth, max_depth) do
      new_state = module.apply_action(world, state, action)
      options = module.actions(world, new_state)
                |> Enum.map(fn {new_action, score} -> max(module, world, new_state, new_action, score, depth + 1, max_depth) end)
                |> Enum.sort(fn {p1, _}, {p2, _} -> p1 >= p2 end)

      case options do
        [] -> {points, [action]}
        [{score, rest} | _] -> {points + score, [action | rest]}
      end
    end
  end

end

defmodule MaxGameTreeTest do
  @behaviour MaxGameTree

  def actions(world, state) do
    Map.get(world, state)
  end

  def apply_action(_world, _state, action) do
    action # action is the same as next state in this simple game
  end

  def test_it() do
    world = %{
      "A" => [{"B", 5}, {"C", 2}],
      "B" => [{"A", 2}, {"D", 3}],
      "C" => [{"B", 7}, {"D", 2}],
      "D" => [{"A", 8}, {"C", 4}, {"E", 12}],
      "E" => []
    }
    {5, ["B"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 1)
    {9, ["C", "B"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 2)
    {20, ["B", "D", "E"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 3)
    {24, ["C", "B", "D", "E"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 4)
    {27, ["B", "A", "B", "D", "E"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 5)
    {36, ["B", "D", "A", "B", "D", "E"]} = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 6)
    #result = MaxGameTree.Search.max(MaxGameTreeTest, world, "A", 7)
    #IO.inspect result
  end
end

MaxGameTreeTest.test_it()
