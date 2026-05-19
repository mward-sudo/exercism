defmodule BoutiqueSuggestions do
  @default_maximum_price 100.00

  def get_combinations(tops, bottoms, options \\ []) do
    maxiumum_price = Keyword.get(options, :maximum_price, @default_maximum_price)

    tops
    |> Stream.flat_map(&get_combinations_for_top(&1, bottoms))
    |> Stream.reject(&outfit_clashes?(&1))
    |> Enum.reject(&outfit_is_too_expensive?(&1, maxiumum_price))
  end

  defp get_combinations_for_top(top, bottoms) do
    Enum.map(bottoms, &{top, &1})
  end

  defp outfit_clashes?({top, bottom}), do: top.base_color == bottom.base_color

  defp outfit_is_too_expensive?({top, bottom}, maximum_price) do
    top.price + bottom.price > maximum_price
  end
end
