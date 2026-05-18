defmodule Triplet do
  @doc """
  Calculates sum of a given triplet of integers.
  """
  @spec sum([non_neg_integer]) :: non_neg_integer
  def sum([a, b, c]), do: a + b + c

  @doc """
  Calculates product of a given triplet of integers.
  """
  @spec product([non_neg_integer]) :: non_neg_integer
  def product([a, b, c]), do: a * b * c

  @doc """
  Determines if a given triplet is pythagorean. That is, do the squares of a and b add up to the square of c?
  """
  @spec pythagorean?([non_neg_integer]) :: boolean
  def pythagorean?([a, b, c]), do: a ** 2 + b ** 2 == c ** 2

  @doc """
  Generates a list of pythagorean triplets whose values add up to a given sum.
  """
  @spec generate(non_neg_integer) :: [list(non_neg_integer)]
  def generate(sum) do
    # Loop over all possible values of 'a' from 1 to sum/2.
    for a <- 1..div(sum, 2),
        # 'b' should be greater than or equal to 'a' to avoid duplicate triplets. It should also be less than sum - a to ensure 'c' is non-negative.
        b <- a..(sum - a),
        # 'c' is calculated as the remaining sum after subtracting 'a' and 'b'.
        c = sum - a - b,
        # Check if 'a', 'b', and 'c' form a Pythagorean triplet.
        pythagorean?([a, b, c]),
        # If they do, add the triplet to the list.
        do: [a, b, c]
  end
end
