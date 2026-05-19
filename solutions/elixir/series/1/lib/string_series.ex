defmodule StringSeries do
  @doc """
  Given a string `s` and a positive integer `size`, return all substrings
  of that size. If `size` is greater than the length of `s`, or less than 1,
  return an empty list.
  """
  @spec slices(s :: String.t(), size :: integer) :: list(String.t())
  def slices(s, size) when size < 1 or size > byte_size(s), do: []

  def slices(s, size) do
    graphemes = String.graphemes(s)

    1..(length(graphemes) - size + 1)
    |> Enum.reverse()
    |> Enum.reduce([], fn index, acc ->
      [
        Enum.slice(graphemes, (index - 1)..(index + size - 2))
        |> Enum.join()
        | acc
      ]
    end)
  end
end
