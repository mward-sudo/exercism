defmodule Username do
  @spec sanitize(charlist()) :: charlist()
  def sanitize(username) do
    username
    |> Enum.flat_map(&replace_german_chars/1)
    |> Enum.filter(&is_valid_char?/1)
  end

  defp replace_german_chars(char) do
    case char do
      ?ä -> 'ae'
      ?ö -> 'oe'
      ?ü -> 'ue'
      ?ß -> 'ss'
      c -> [c]
    end
  end

  defp is_valid_char?(char) do
    case char do
      ?_ -> true
      char when char in ?a..?z -> true
      _char -> false
    end
  end
end
