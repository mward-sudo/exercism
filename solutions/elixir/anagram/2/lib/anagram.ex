defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, `base`.
  """
  @spec match(base :: String.t(), candidates :: [String.t()]) :: [String.t()]
  def match(base, candidates) do
    Enum.filter(
      candidates,
      &anagram?(String.downcase(base), String.downcase(&1))
    )
  end

  # Returns true if the candidate is an anagram of the base string
  # Returns false otherwise
  # Returns false if the candidate is equal to the base string
  # Returns false if the candidate is not the same length as the base string
  @spec anagram?(base :: binary(), candidate :: binary()) :: boolean()
  defp anagram?(base, candidate)
       when base !== candidate and bit_size(base) == bit_size(candidate) do
    candidate
    |> String.graphemes()
    # Reduce the graphemes into a boolean value indicating if the graphemes are
    # a subset of the base string
    |> Enum.reduce_while(base, fn letter, acc ->
      if String.contains?(acc, letter),
        # If the base string contains the letter, return the base string with
        # the letter removed
        do: {:cont, String.replace(acc, letter, "", global: false)},
        else: {:halt, false}
    end)
  end

  defp anagram?(_, _), do: false
end
