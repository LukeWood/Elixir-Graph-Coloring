defmodule GraphColoringTest do
  use ExUnit.Case

  test "Graph coloring function works properly" do
    assert GraphColoring.color_graph([0, 1, 2], [[], [], []]) == %{0 => 0, 1 => 0, 2 => 0}
    assert GraphColoring.color_graph([0, 1, 2], [[0], [0], [0,1]]) == %{0 => 0, 1 => 1, 2 => 2}
  end

  test "construct node to degree map" do
    import GraphColoring.ShortestVertexLast
    degree_map = construct_node_to_degree([[1],[]])
    assert Map.get(degree_map, 0) == 1
  end

  test "construct degree to node" do
    import GraphColoring.ShortestVertexLast
    degree_to_nodes = construct_node_to_degree([[], [], []]) |>
      construct_degree_to_nodes()

    assert Map.get(degree_to_nodes, 0) |> MapSet.size == 3
  end


  test "Shortest Vertex Last Ordering" do
    import GraphColoring.ShortestVertexLast
    {ordering, _degree_when_removed} = generate_ordering(
      [
        [1, 2, 3],
        [0],
        [0, 3, 1],
        [1]
      ]
    )
    assert ordering == [2, 0, 3, 1]
  end

end
