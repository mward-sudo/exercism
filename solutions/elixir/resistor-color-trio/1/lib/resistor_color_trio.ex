defmodule ResistorColorTrio do
  @color_values %{
    black: 0,
    brown: 1,
    red: 2,
    orange: 3,
    yellow: 4,
    green: 5,
    blue: 6,
    violet: 7,
    grey: 8,
    white: 9
  }

  @doc """
  Calculate the resistance value in ohms from resistor colors
  """
  @spec label(colors :: [atom]) :: {number, :ohms | :kiloohms | :megaohms | :gigaohms}
  def label(colors) do
    resistance_in_ohms(colors) |> resistance_with_prefix()
  end

  defp resistance_in_ohms(colors) do
    colors
    |> Enum.map(fn color -> @color_values[color] end)
    |> expand_third_value_to_zero_digits()
    |> Integer.undigits()
  end

  defp expand_third_value_to_zero_digits([first, second, third | _rest]) do
    [first, second | List.duplicate(0, third)]
  end

  defp resistance_with_prefix(ohms) when ohms < 1000, do: {ohms, :ohms}
  defp resistance_with_prefix(ohms) when ohms < 1_000_000, do: {ohms / 1000, :kiloohms}
  defp resistance_with_prefix(ohms) when ohms < 1_000_000_000, do: {ohms / 1_000_000, :megaohms}
  defp resistance_with_prefix(ohms), do: {ohms / 1_000_000_000, :gigaohms}
end
