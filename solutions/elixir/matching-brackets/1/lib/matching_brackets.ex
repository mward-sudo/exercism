defmodule MatchingBrackets do
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
      "(" -> [")" | stack]
      "[" -> ["]" | stack]
      "{" -> ["}" | stack]
      ")" -> pop_if_match(")", stack)
      "]" -> pop_if_match("]", stack)
      "}" -> pop_if_match("}", stack)
      # ignore other characters
      _ -> stack
    end
  end

  defp pop_if_match(char, [char | rest]), do: rest
  # invalid match
  defp pop_if_match(_, _), do: [nil]
end
