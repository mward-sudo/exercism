defmodule RangeNumber do
  @enforce_keys [:number]
  defstruct [:number, composite: false]
end

defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) when limit < 2, do: []

  def primes_to(limit) do
    2..limit
    |> Enum.map(fn number -> %RangeNumber{number: number} end)
    |> mark_composites(limit)
    |> Enum.reject(fn number -> number.composite end)
    |> Enum.map(fn number -> number.number end)
  end

  defp mark_composites([], _), do: []

  # Numbers marked as composite do not need to be checked for multiples.
  # Continue to the next number.
  defp mark_composites([head | tail], limit) when head.composite do
    [head | mark_composites(tail, limit)]
  end

  # Numbers not marked as composite need to be checked for multiples.
  defp mark_composites([head | tail], limit) do
    new_tail = mark_as_composite_multiples_of(head.number, tail, limit)
    [head | mark_composites(new_tail, limit)]
  end

  defp mark_as_composite_multiples_of(number, range, limit) do
    multiples = for n <- 2..limit, do: number * n

    range
    |> Enum.map(fn range_number ->
      %{range_number | composite: mark_as_multiple?(range_number, multiples)}
    end)
  end

  defp mark_as_multiple?(number, _multiples) when number.composite, do: true
  defp mark_as_multiple?(number, multiples) when number.number in multiples, do: true
  defp mark_as_multiple?(_number, _multiples), do: false
end
