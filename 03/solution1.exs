defmodule WirePath do
  defp next_point(:U, {x0, y0}), do: {x0, y0+1}
  defp next_point(:D, {x0, y0}), do: {x0, y0-1}
  defp next_point(:L, {x0, y0}), do: {x0-1, y0}
  defp next_point(:R, {x0, y0}), do: {x0+1, y0}

  defp expand_repeats({dir, n}) do
    List.duplicate(dir, n)
  end

  def path_points(path) do
    path
    |> Stream.flat_map(&expand_repeats/1)
    |> Stream.scan({0, 0}, &next_point/2)
    |> MapSet.new()
  end

  def from_origin({x0, y0}), do: abs(x0) + abs(y0)

  def read_path() do
    IO.read(:stdio, :line)
    |> String.trim()
    |> String.split(",")
    |> Stream.map(&parse_segment/1)
    |> path_points()
  end

  defp parse_segment("U" <> len), do: {:U, String.to_integer(len)}
  defp parse_segment("D" <> len), do: {:D, String.to_integer(len)}
  defp parse_segment("L" <> len), do: {:L, String.to_integer(len)}
  defp parse_segment("R" <> len), do: {:R, String.to_integer(len)}
end

# wire1 = [{:R, 8}, {:U, 5}, {:L, 5}, {:D, 3}] |> WirePath.path_points()
# wire2 = [{:U, 7}, {:R, 6}, {:D, 4}, {:L, 4}] |> WirePath.path_points()
wire1 = WirePath.read_path()
wire2 = WirePath.read_path()

MapSet.intersection(wire1, wire2) |> Enum.sort_by(&WirePath.from_origin/1) |> hd() |> IO.inspect()
