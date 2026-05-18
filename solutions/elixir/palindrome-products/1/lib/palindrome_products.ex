defmodule PalindromeProducts do
  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: map
  def generate(max_factor, min_factor \\ 1)

  def generate(max_factor, min_factor) when max_factor < min_factor do
    raise ArgumentError, "max_factor must be greater than or equal to min_factor"
  end

  def generate(max_factor, min_factor) do
    min_factor..max_factor
    |> Enum.flat_map(&generate_palindromes(&1, max_factor))
    |> group_by_elements()
  end

  defp generate_palindromes(x, max_factor) do
    for y <- x..max_factor,
        product = x * y,
        is_palindrome?(product),
        do: {product, [x, y]}
  end

  defp group_by_elements(collection) do
    collection
    |> Enum.group_by(fn {x, _} -> x end, fn {_, y} -> y end)
  end

  defp is_palindrome?(number) do
    str = Integer.to_string(number)
    str == String.reverse(str)
  end
end
