defmodule PwGuess do
  def nondec(_, 0), do: [[]]

  def nondec(starts_with, len) do
    starts_with..9
    |> Stream.flat_map(fn digit ->
      nondec(digit, len-1)
      |> Stream.map(fn digits -> [digit | digits] end)
    end)
  end

  def has_repeat?([_]), do: false
  def has_repeat?([a, b | rest]) do
    if a == b do
      true
    else
      has_repeat?([b | rest])
    end
  end

  def to_integer(digits), do: digits |> Enum.reverse() |> do_to_integer()

  defp do_to_integer([d]), do: d
  defp do_to_integer([d | rest]), do: d + 10*do_to_integer(rest)

  def in_range(n, n_min, n_max), do: Enum.member?(n_min..n_max, n)
end

PwGuess.nondec(1, 6)
|> Stream.filter(&PwGuess.has_repeat?/1)
|> Stream.map(&PwGuess.to_integer/1)
|> Stream.filter(&PwGuess.in_range(&1, 183564, 657474))
# |> Enum.to_list() |> IO.inspect(charlists: false)
|> Stream.scan(0, fn _, acc -> acc + 1 end)
|> Stream.take(-1)
|> Enum.to_list()
|> hd()
|> IO.inspect()
