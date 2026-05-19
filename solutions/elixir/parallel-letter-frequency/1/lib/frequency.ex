defmodule Frequency do
  @spec frequency([String.t()], pos_integer) :: map
  def frequency([], _workers), do: %{}

  def frequency(texts, workers) do
    texts
    |> Task.async_stream(&tally_letters/1, max_concurrency: workers)
    |> Enum.reduce(%{}, &merge_letter_tallys/2)
  end

  @spec tally_letters(String.t()) :: map()
  defp tally_letters(string) do
    string
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(&unicode_letter?/1)
    |> Enum.frequencies()
  end

  @spec merge_letter_tallys({:ok, map()}, map()) :: map()
  defp merge_letter_tallys({:ok, letter_tally}, acc),
    do: Map.merge(acc, letter_tally, &sum_letter_counts/3)

  @spec sum_letter_counts(atom(), integer(), integer()) :: integer()
  defp sum_letter_counts(_, c1, c2), do: c1 + c2

  @spec unicode_letter?(String.t()) :: boolean
  defp unicode_letter?(letter), do: String.match?(letter, ~r/\p{L}/)
end
