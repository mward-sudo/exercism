defmodule PrimeFactors do
  @doc """
  Compute the prime factors for 'number'.

  The prime factors are prime numbers that when multiplied give the desired
  number.

  The prime factors of 'number' will be ordered lowest to highest.
  """
  @spec factors_for(pos_integer) :: [pos_integer]
  def factors_for(number) do
    factors_for(number, 2, [])
    |> Enum.reverse()
  end

  defp factors_for(1, _current, factors), do: factors

  defp factors_for(number, current, factors) do
    if rem(number, current) == 0 do
      factors_for(div(number, current), current, [current | factors])
    else
      factors_for(number, current + 1, factors)
    end
  end
end
