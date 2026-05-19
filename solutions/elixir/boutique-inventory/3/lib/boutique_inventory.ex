defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, & &1.price)
  end

  def with_missing_price(inventory) do
    Enum.filter(inventory, &(!&1.price))
  end

  def update_names(inventory, old_word, new_word) do
    Enum.map(inventory, fn %{name: name} = item ->
      %{item | name: String.replace(name, old_word, new_word)}
    end)
  end

  def increase_quantity(item, count) do
    %{quantity_by_size: quantities} = item

    # Adds the count to the quantity of each size
    new_quantities =
      quantities
      |> Enum.map(fn {k, v} -> {k, v + count} end)
      |> Map.new()

    # Updates the item with the new quantities
    %{item | quantity_by_size: new_quantities}
  end

  def total_quantity(item) do
    %{quantity_by_size: quantities} = item

    Enum.reduce(quantities, 0, fn {_size, quantity}, total_quantity ->
      quantity + total_quantity
    end)
  end
end
