defmodule Proverb do
  @doc """
  Generate a proverb from a list of strings.
  """
  @spec recite(strings :: [String.t()]) :: String.t()
  def recite(strings) when length(strings) == 0, do: ""

  def recite(strings) when length(strings) == 1,
    do: "And all for the want of a #{List.first(strings)}.\n"

  def recite(strings) do
    strings
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&generate_proverb/1)
    |> Enum.join("\n")
    |> (&(&1 <> "\nAnd all for the want of a #{List.first(strings)}.\n")).()
  end

  defp generate_proverb([first, second]) do
    "For want of a #{first} the #{second} was lost."
  end
end
