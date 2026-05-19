defmodule BoutiqueSuggestions do
  @default_maximum_price 100.00

  def get_combinations(tops, bottoms, options \\ []) do
    options = Keyword.merge([maximum_price: @default_maximum_price], options)

    for top <- tops,
        bottom <- bottoms,
        top.base_color != bottom.base_color,
        top.price + bottom.price <= options[:maximum_price] do
      {top, bottom}
    end
  end
end
