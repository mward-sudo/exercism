defmodule Acronym do
  @doc """
  Generate an acronym from a string.
  "This is a string" => "TIAS"
  """
  @spec abbreviate(String.t()) :: String.t()
  def abbreviate(string) do
    string
    |> String.replace("-", " ")
    |> remove_punctuation()
    |> String.split(" ")
    |> map_to_list_of_first_letters()
    |> Enum.join()
    |> String.upcase()
  end

  defp remove_punctuation(string), do: String.replace(string, ~r/[[:punct:]]/, "")

  defp map_to_list_of_first_letters(list), do: Enum.map(list, fn word -> String.at(word, 0) end)
end
