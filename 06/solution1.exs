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
  end

  def count_orbits_for(graph, orbiter) do
    :digraph.get_path(graph, orbiter, "COM")
    |> Enum.drop(1)
    |> length()
  end

  def count_all_orbits(graph) do
    all_orbiters(graph)
    |> Map.new(fn orbiter -> {orbiter, count_orbits_for(graph, orbiter)} end)
  end

  def all_orbiters(graph) do
    :digraph.vertices(graph)
    |> List.delete("COM")
  end

  defp parse_one(<<center::binary-size(3), ")", orbiter::binary-size(3)>>) do
    {center, orbiter}
  end
end

graph = :digraph.new([:acyclic])

OrbitCounter.load_input(graph)

OrbitCounter.count_all_orbits(graph) |> Map.values() |> Enum.sum() |> IO.inspect()
