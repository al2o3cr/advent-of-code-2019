defmodule PwGuess do
  def nondec(_, 0), do: [[]]

  def nondec(starts_with, len) do
    starts_with..9
    |> Stream.flat_map(fn digit ->
      nondec(digit, len-1)
      |> Stream.map(fn digits -> [digit | digits] end)
    end)
  end

  def has_two_repeat?([]), do: false
  def has_two_repeat?([_]), do: false
  def has_two_repeat?([a, b | rest]) do
    cond do
      a == b ->
        has_zero?(a, rest) || has_two_repeat?(rest, a)

      has_one?(b, rest) ->
        true

      true ->
        has_two_repeat?([b | rest])
    end
  end

  defp has_two_repeat?([a | rest], a), do: has_two_repeat?(rest, a)
  defp has_two_repeat?(rest, _), do: has_two_repeat?(rest)

  defp has_one?(_, []), do: false
  defp has_one?(digit, [digit | rest]), do: has_zero?(digit, rest)
  defp has_one?(digit, [_ | rest]), do: has_one?(digit, rest)

  defp has_zero?(_, []), do: true
  defp has_zero?(digit, [digit | _]), do: false
  defp has_zero?(digit, [_ | rest]), do: has_zero?(digit, rest)

  def to_integer(digits), do: digits |> Enum.reverse() |> do_to_integer()

  defp do_to_integer([d]), do: d
  defp do_to_integer([d | rest]), do: d + 10*do_to_integer(rest)

  def in_range(n, n_min, n_max), do: Enum.member?(n_min..n_max, n)
end

PwGuess.nondec(1, 6)
|> Stream.filter(&PwGuess.has_two_repeat?/1)
|> Stream.map(&PwGuess.to_integer/1)
|> Stream.filter(&PwGuess.in_range(&1, 183564, 657474))
|> Stream.scan(0, fn _, acc -> acc + 1 end)
|> Stream.take(-1)
|> Enum.to_list()
|> hd()
|> IO.inspect()
