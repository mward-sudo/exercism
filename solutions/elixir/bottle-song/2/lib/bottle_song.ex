defmodule BottleSong do
  @moduledoc """
  Handles lyrics of the popular children song: Ten Green Bottles
  """

  @spec recite(pos_integer, pos_integer) :: String.t()
  def recite(start_bottle, take_down) do
    start_bottle..max(start_bottle - take_down + 1, 1)
    |> Enum.map(&verse/1)
    |> Enum.join("\n\n")
  end

  defp verse(1), do: singular_verse()
  defp verse(n), do: plural_verse(n, number_word(n), number_word(n - 1))

  defp singular_verse do
    """
    One green bottle hanging on the wall,
    One green bottle hanging on the wall,
    And if one green bottle should accidentally fall,
    There'll be no green bottles hanging on the wall.\
    """
  end

  defp plural_verse(_n, current, next) do
    """
    #{String.capitalize(current)} green bottles hanging on the wall,
    #{String.capitalize(current)} green bottles hanging on the wall,
    And if one green bottle should accidentally fall,
    There'll be #{next} green bottle#{if next == "one", do: "", else: "s"} hanging on the wall.\
    """
  end

  defp number_word(n) when n >= 1 and n <= 10 do
    ~w(one two three four five six seven eight nine ten)
    |> Enum.at(n - 1)
  end
end
