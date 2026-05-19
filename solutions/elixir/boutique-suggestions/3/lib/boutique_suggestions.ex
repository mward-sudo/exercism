defmodule BoutiqueSuggestions do
  @default_maximum_price 100.00

  def get_combinations(tops, bottoms, options \\ []) do
    max_price = Keyword.get(options, :maximum_price, @default_maximum_price)

    for top <- tops,
        bottom <- bottoms,
        not colors_clash?(top, bottom),
        not over_budget?(top, bottom, max_price) do
      {top, bottom}
    end
  end

  # Straightforward test to avoid outfits with the same base color
  defp colors_clash?(%{base_color: top_color} = _top, %{base_color: bottom_color} = _bottom),
    do: top_color == bottom_color

  # Test to avoid outfits that are over budget
  defp over_budget?(%{price: p1} = _top, %{price: p2} = _bottom, max_price),
    do: p1 + p2 > max_price
end
