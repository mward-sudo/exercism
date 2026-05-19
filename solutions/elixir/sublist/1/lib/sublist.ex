defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  def compare(a, a), do: :equal

  def compare(a, b) do
    cond do
      a |> subset_of?(b) -> :sublist
      b |> subset_of?(a) -> :superlist
      true -> :unequal
    end
  end

  defp subset_of?([], _), do: true

  defp subset_of?(a, b) do
    Stream.chunk_every(b, length(a), 1, :discard)
    |> Enum.any?(fn elem -> elem === a end)
  end
end
