defmodule CandidateNumber do
  @enforce_keys [:number]
  defstruct [:number, composite: false]
end

defmodule CandidatePrimeNumbers do
  @doc """
  Generates a list of candidate prime numbers up to a given limit.
  """
  @spec generate(non_neg_integer) :: [%CandidateNumber{}]
  def generate(limit) when limit < 2, do: []

  def generate(limit) do
    Enum.map(2..limit, fn candidate_number -> %CandidateNumber{number: candidate_number} end)
  end

  @doc """
  Given a list of %CandidateNumber, generates a list of primes up to a given limit.
  """
  @spec primes_list([%CandidateNumber{}], non_neg_integer) :: [non_neg_integer]
  def primes_list(candidate_numbers, limit) do
    candidate_numbers
    |> mark_composites(limit)
    |> Enum.reject(fn candidate_number -> candidate_number.composite end)
    |> Enum.map(fn prime_number -> prime_number.number end)
  end

  defp mark_composites([] = _candidate_numbers, _limit), do: []

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

    Enum.map(range, fn range_number ->
      %{range_number | composite: mark_as_composite?(range_number, multiples)}
    end)
  end

  defp mark_as_composite?(number, _) when number.composite, do: true
  defp mark_as_composite?(number, multiples), do: number.number in multiples
end

defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(limit) when limit < 2, do: []

  def primes_to(limit) do
    CandidatePrimeNumbers.generate(limit)
    |> CandidatePrimeNumbers.primes_list(limit)
  end
end
