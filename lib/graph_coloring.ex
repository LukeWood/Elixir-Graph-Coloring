defmodule GraphColoring do

  defp next_color(neighbor_colors, current_color) do
    if MapSet.member?(neighbor_colors, current_color) do
      next_color(neighbor_colors, current_color+1)
    else
      current_color
    end
  end

  defp color_node(node_num, neighbors, colors) do
    neighbor_colors = Enum.map(neighbors, &(Map.get(colors, &1))) |> Enum.into(MapSet.new)
    Map.put(colors, node_num, next_color(neighbor_colors, 0))
  end

  def color_graph(ordering, adj_list) do
      Enum.map(ordering,
        fn node -> {node, Enum.at(adj_list, node)} end
      ) |>
      Enum.reduce(
        %{},
        fn {node, neighbors}, coloring ->
          color_node(node, neighbors, coloring)
        end
      )
  end

end
