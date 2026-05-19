defmodule WordCount do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.

  A word will always be one of:
  1. A number composed of one or more ASCII digits (ie "0" or "1234") OR
  2. A simple word composed of one or more ASCII letters (ie "a" or "they") OR
  3. A contraction of two simple words joined by a single apostrophe (ie "it's" or "they're")
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    sentence
    |> String.replace(~r/[^A-Za-zÀ-ž0-9-']/, " ")
    |> String.downcase()
    |> String.split()
    |> Enum.map(fn word -> String.trim(word, "'") end)
    |> Enum.frequencies()
  end
end
