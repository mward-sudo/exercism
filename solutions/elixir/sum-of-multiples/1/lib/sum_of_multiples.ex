defmodule SumOfMultiples do
  @doc """
  Adds up all numbers from 1 to a given end number that are multiples of the factors provided.
  """
  @spec to(non_neg_integer, [non_neg_integer]) :: non_neg_integer
  def to(limit, factors) do
    factors
    |> Enum.flat_map(&multiples(&1, limit))
    |> Enum.uniq()
    |> Enum.sum()
  end

  def multiples(factor, limit) do
    1..(limit - 1)
    |> Enum.filter(&(&1 * factor < limit))
    |> Enum.map(&(&1 * factor))
  end
end
