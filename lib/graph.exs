defmodule Graph do

  @type graph :: any()
  @type graph_node :: any()

  @callback neighbours(graph, graph_node) :: [graph_node]

  defmodule Search do
    # Performs a breadth first search on the graph.
    # Returns a list of the path from the root to the goal
    # https://en.wikipedia.org/wiki/Breadth-first_search#Pseudocode
    def bfs(graph_module, graph, root, goal_test) do
      # Paths keeps track of all visited and the path there.
      # It is a map where the key is the visited node and the value is the parent node
      paths = %{root => nil}
      queue = :queue.in(root, :queue.new())
      bfs(graph_module, graph, goal_test, queue, paths)
    end

    defp bfs(_graph_module, _graph, _goal_test, {[], []}, _paths) do
      {:not_found}
    end
    defp bfs(graph_module, graph, goal_test, queue, paths) do
      {{:value, graph_node}, out_queue} = :queue.out(queue)
      if goal_test.(graph, graph_node) do
        {:found, graph_node, bfs_to_list(paths, graph_node, [])}
      else
        neighbour_nodes = graph_module.neighbours(graph, graph_node)
        {new_queue, new_paths} = bfs_explore(graph_node, neighbour_nodes, out_queue, paths)
        bfs(graph_module, graph, goal_test, new_queue, new_paths)
      end
    end

    defp bfs_explore(_graph_node, [], queue, paths) do
      {queue, paths}
    end
    defp bfs_explore(graph_node, [neighbour | rest], queue, paths) do
      if Map.has_key?(paths, neighbour) do
        bfs_explore(graph_node, rest, queue, paths)
      else
        new_paths = Map.put(paths, neighbour, graph_node)
        new_queue = :queue.in(neighbour, queue)
        bfs_explore(graph_node, rest, new_queue, new_paths)
      end
    end

    defp bfs_to_list(_paths, nil, list) do
      list
    end
    defp bfs_to_list(paths, node, list) do
      new_list = [node | list]
      parent_node = Map.get(paths, node)
      bfs_to_list(paths, parent_node, new_list)
    end
  end
end

defmodule GraphTest do
  @behaviour Graph

  def neighbours(graph, graph_node) do
    Map.get(graph, graph_node)
  end

  def test_it() do
    graph = %{
      "1" => ["2", "3"],
      "2" => ["1", "3", "5"],
      "3" => ["1", "2", "4"],
      "4" => ["3", "5", "6"],
      "5" => ["2", "4", "6", "7"],
      "6" => ["4", "5"],
      "7" => ["5", "8", "9"],
      "8" => ["7", "9"],
      "9" => ["7", "8"],
    }
    {:found, "9", path} = Graph.Search.bfs(GraphTest, graph, "1", fn _, n -> n == "9" end)
    ["1", "2", "5", "7", "9"] = path

    bad_graph = %{
      "1" => ["2", "3"],
      "2" => ["1", "3"],
      "3" => ["1", "2"],
      "4" => ["5", "6"],
      "5" => ["4", "6"],
      "6" => ["4", "5"]
    }
    {:not_found} = Graph.Search.bfs(GraphTest, bad_graph, "1", fn _, n -> n == "6" end)
  end
end

GraphTest.test_it()