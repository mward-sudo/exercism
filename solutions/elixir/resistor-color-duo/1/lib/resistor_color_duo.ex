defmodule ResistorColorDuo do
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
  Calculate a resistance value from two colors
  """
  @spec value(colors :: [atom]) :: integer
  def value(colors) do
    [color1, color2] = Enum.take(colors, 2)
    @color_values[color1] * 10 + @color_values[color2]
  end
end
