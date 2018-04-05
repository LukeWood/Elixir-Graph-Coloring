defmodule GraphColoring.ShortestVertexLast do

  defp degree_map_reducer({node, degree}, degree_map) do
    map_set = Map.get(degree_map, degree, MapSet.new)
    map_set = MapSet.put(map_set, node)
    Map.put(degree_map, degree, map_set)
  end

  def construct_degree_to_nodes(node_to_degree) do
    Enum.reduce(node_to_degree, %{}, &degree_map_reducer/2)
  end

  def construct_node_to_degree(adj_list) do
    Enum.with_index(adj_list) |>
      Enum.map(fn {neighbors, node} -> {node, length(neighbors)} end) |>
      Enum.into(%{})
  end

  def generate_ordering(adj_list) do
    node_to_degree = construct_node_to_degree(adj_list)
    degree_to_nodes = construct_degree_to_nodes(node_to_degree)

    adj_list = Enum.with_index(adj_list) |>
      Enum.map(fn {neighbors, node} -> {node, neighbors} end) |>
      Enum.into(%{})
    generate_ordering_recursive(adj_list, node_to_degree, degree_to_nodes, %{}, [], 0)
  end

  defp first_elem_of_mapset(mapset) do
    Enum.at(mapset, 0)
  end

  defp next_node(degree_to_nodes, index\\0) do
    map_set = Map.get(degree_to_nodes, index, MapSet.new)
    if MapSet.size(map_set) == 0 do
      next_node(degree_to_nodes, index+1)
    else
      first_elem_of_mapset(map_set)
    end
  end

  defp decrement_degree(neighbor, node_to_degree) do
    Map.update!(node_to_degree, neighbor, &(&1-1))
  end

  defp curry_remove_neighbor(node_to_degree) do
    fn neighbor, degree_to_nodes ->
      deg = Map.get(node_to_degree, neighbor)
      old_set = Map.get(degree_to_nodes, deg)
      new_set  = if MapSet.member?(old_set, neighbor) do
        Map.get(degree_to_nodes, deg-1, MapSet.new) |> MapSet.put(neighbor)
      else
        Map.get(degree_to_nodes, deg-1, MapSet.new)
      end
      degree_to_nodes |>
        Map.put(deg,   old_set) |>
        Map.put(deg-1, new_set)
    end
  end

  defp remove_node(adj_list, node_to_degree, degree_to_nodes, node) do
    neighbors = Map.get(adj_list, node)
    degree = Map.get(node_to_degree, node)

    degree_to_nodes = Map.update!(degree_to_nodes, degree, fn mapset -> MapSet.delete(mapset, node) end)
    degree_to_nodes = Enum.reduce(neighbors, degree_to_nodes, curry_remove_neighbor(node_to_degree))

    node_to_degree = Enum.reduce(neighbors, node_to_degree, &decrement_degree/2)
    {node_to_degree, degree_to_nodes}
  end

  defp generate_ordering_recursive(adj_list, _node_to_degree, _degree_to_nodes, degrees_when_removed, ordering, count) when map_size(adj_list) == count do
    {ordering |> Enum.reverse, degrees_when_removed}
  end
  defp generate_ordering_recursive( adj_list,  node_to_degree, degree_to_nodes, degrees_when_removed, ordering, count) do
    node = next_node(degree_to_nodes)
    degrees_when_removed = Map.put(degrees_when_removed, node, Map.get(node_to_degree, node))
    ordering = [node | ordering]
    {node_to_degree, degree_to_nodes} = remove_node(adj_list, node_to_degree, degree_to_nodes, node)
    generate_ordering_recursive(adj_list,  node_to_degree, degree_to_nodes, degrees_when_removed, ordering, count+1)
  end

end
