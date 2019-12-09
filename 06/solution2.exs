defmodule OrbitCounter do
  def load_input(graph) do
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_one/1)
    |> Stream.each(fn {center, orbiter} -> insert(graph, center, orbiter) end)
    |> Stream.run()
  end

  def insert(graph, center, orbiter) do
    :digraph.add_vertex(graph, center)
    :digraph.add_vertex(graph, orbiter)
    :digraph.add_edge(graph, orbiter, center)
    :digraph.add_edge(graph, center, orbiter)
  end

  def get_path(graph) do
    :digraph.get_path(graph, "YOU", "SAN")
    |> List.delete("YOU")
    |> List.delete("SAN")
  end

  defp parse_one(<<center::binary-size(3), ")", orbiter::binary-size(3)>>) do
    {center, orbiter}
  end
end

graph = :digraph.new()

OrbitCounter.load_input(graph)

transfer_path = OrbitCounter.get_path(graph)

IO.inspect(length(transfer_path) - 1)
