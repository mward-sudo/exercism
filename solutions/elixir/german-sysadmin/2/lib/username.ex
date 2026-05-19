defmodule Username do
  @spec sanitize(charlist()) :: charlist()
  def sanitize(username) do
    username
    |> Enum.flat_map(&replace_german_characters/1)
    |> Enum.filter(&valid_character?/1)
  end

  defp replace_german_characters(char) do
    case char do
      ?ä -> 'ae'
      ?ö -> 'oe'
      ?ü -> 'ue'
      ?ß -> 'ss'
      c -> [c]
    end
  end

  defp valid_character?(char) do
    case char do
      ?_ -> true
      char when char in ?a..?z -> true
      _char -> false
    end
  end
end
