defmodule KitchenCalculator do
  @unit_ratios %{
    milliliter: 1,
    cup: 240,
    fluid_ounce: 30,
    teaspoon: 5,
    tablespoon: 15
  }

  def get_volume({_type, volume}), do: volume

  def to_milliliter({unit, volume}) do
    {:milliliter, volume * @unit_ratios[unit]}
  end

  def from_milliliter({:milliliter, volume}, target_unit) do
    {target_unit, volume / @unit_ratios[target_unit]}
  end

  def convert(from_pair, target_unit) do
    to_milliliter(from_pair)
    |> from_milliliter(target_unit)
  end
end
