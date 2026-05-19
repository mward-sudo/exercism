defmodule House do
  @lines [
    {"This is the house that Jack built.\n", " that lay in the house that Jack built.\n"},
    {"This is the malt", " that ate the malt"},
    {"This is the rat", " that killed the rat"},
    {"This is the cat", " that worried the cat"},
    {"This is the dog", " that tossed the dog"},
    {"This is the cow with the crumpled horn", " that milked the cow with the crumpled horn"},
    {"This is the maiden all forlorn", " that kissed the maiden all forlorn"},
    {"This is the man all tattered and torn", " that married the man all tattered and torn"},
    {"This is the priest all shaven and shorn", " that woke the priest all shaven and shorn"},
    {"This is the rooster that crowed in the morn",
     " that kept the rooster that crowed in the morn"},
    {"This is the farmer sowing his corn", " that belonged to the farmer sowing his corn"},
    {"This is the horse and the hound and the horn", ""}
  ]

  @doc """
  Return verses of the nursery rhyme 'This is the House that Jack Built'.
  """
  @spec recite(start :: integer, stop :: integer) :: String.t()
  def recite(start, stop) do
    for iteration <- stop..start, line <- 1..iteration do
      [get_line(line, line == iteration)]
    end
    |> Enum.reverse()
    |> Enum.join()
  end

  defp get_line(line, first_line?)
  defp get_line(line, true), do: get_phrases(line) |> elem(0)
  defp get_line(line, false), do: get_phrases(line) |> elem(1)

  defp get_phrases(line), do: Enum.at(@lines, line - 1)
end
