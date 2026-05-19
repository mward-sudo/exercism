defmodule KitchenCalculator do
  @units %{
    milliliter: {:milliliter, 1},
    cup: {:milliliter, 240},
    fluid_ounce: {:milliliter, 30},
    teaspoon: {:milliliter, 5},
    tablespoon: {:milliliter, 15}
  }

  def get_volume({_type, volume}), do: volume

  def to_milliliter({type, volume}) do
    @units
    |> Map.get(type)
    |> get_volume
    |> then(&(volume * &1))
    |> then(&{:milliliter, &1})
  end

  def from_milliliter({:milliliter, volume}, target_unit) do
    @units
    |> Map.get(target_unit)
    |> get_volume
    |> then(&(volume / &1))
    |> then(&{target_unit, &1})
  end

  def convert(from_pair, target_unit) do
    to_milliliter(from_pair)
    |> from_milliliter(target_unit)
  end
end
