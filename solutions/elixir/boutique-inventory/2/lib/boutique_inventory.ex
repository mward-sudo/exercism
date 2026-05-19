defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    inventory
    |> Enum.sort_by(& &1.price)
  end

  def with_missing_price(inventory) do
    inventory
    |> Enum.filter(fn %{price: price} = _item ->
      price == nil
    end)
  end

  def update_names(inventory, old_word, new_word) do
    inventory
    |> Enum.map(fn %{name: name} = item ->
      Map.update(
        item,
        :name,
        nil,
        fn _ -> String.replace(name, old_word, new_word) end
      )
    end)
  end

  def increase_quantity(item, count) do
    %{quantity_by_size: quantities} = item

    # Adds the count to the quantity of each size
    new_quantities =
      quantities
      |> Enum.map(fn {k, v} -> {k, v + count} end)
      |> Enum.into(%{})

    # Updates the item with the new quantities
    Map.update(
      item,
      :quantity_by_size,
      nil,
      fn _ -> new_quantities end
    )
  end

  def total_quantity(item) do
    %{quantity_by_size: quantities} = item

    quantities
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reduce(0, fn acc, v -> acc + v end)
  end
end
