defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, `base`.
  """
  @spec match(base :: String.t(), candidates :: [String.t()]) :: [String.t()]
  def match(base, candidates) do
    Enum.filter(
      candidates,
      &is_anagram(String.downcase(base), String.downcase(&1))
    )
  end

  @doc """
  Returns `true` if `candidate` is a case sensitive anagram of `base`,
  `false` otherwise.

  Returns `false` if `base == candidate`, or if `base` is not the same
  length as `candidate`.
  """
  @spec is_anagram(base :: binary(), candidate :: binary()) :: boolean()
  def is_anagram(base, candidate)
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

  def is_anagram(_, _), do: false
end
