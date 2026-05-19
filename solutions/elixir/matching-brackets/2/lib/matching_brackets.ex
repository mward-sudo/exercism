defmodule MatchingBrackets do
  @bracket_pairs %{
    "(" => ")",
    "[" => "]",
    "{" => "}"
  }
  @closing_brackets Map.values(@bracket_pairs)

  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(str) do
    str
    |> String.graphemes()
    |> Enum.reduce([], &process_char/2)
    |> Enum.empty?()
  end

  defp process_char(char, stack) do
    case char do
      char when is_map_key(@bracket_pairs, char) ->
        [@bracket_pairs[char] | stack]

      char when char in @closing_brackets ->
        pop_if_match(char, stack)

      _ ->
        stack
    end
  end

  defp pop_if_match(char, [char | rest]), do: rest
  # invalid match
  defp pop_if_match(_, _), do: [false]
end
