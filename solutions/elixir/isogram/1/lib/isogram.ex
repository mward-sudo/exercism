defmodule Isogram do
  @doc """
  Determines if a word or sentence is an isogram
  """
  @spec isogram?(String.t()) :: boolean
  def isogram?(sentence) do
    graphemes =
      sentence
      |> String.downcase()
      |> String.replace(~r/[^a-z]/, "")
      |> String.graphemes()

    graphemes == Enum.uniq(graphemes)
  end
end
