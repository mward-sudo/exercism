defmodule Allergies do
  import Bitwise

  @allergies %{
    "eggs" => 0b1,
    "peanuts" => 0b10,
    "shellfish" => 0b100,
    "strawberries" => 0b1_000,
    "tomatoes" => 0b10_000,
    "chocolate" => 0b100_000,
    "pollen" => 0b1_000_000,
    "cats" => 0b10_000_000
  }

  @doc """
  List the allergies for which the corresponding flag bit is true.
  """
  @spec list(non_neg_integer) :: [String.t()]
  def list(flags) do
    @allergies
    |> Map.keys()
    |> Enum.filter(&allergic_to?(flags, &1))
  end

  @doc """
  Returns whether the corresponding flag bit in 'flags' is set for the item.
  """
  @spec allergic_to?(non_neg_integer, String.t()) :: boolean
  def allergic_to?(flags, item) do
    (@allergies[item] &&& flags) > 0
  end
end
