defmodule PascalsTriangle do
  @doc """
  Calculates the rows factorial a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(num), do: Enum.map(0..(num - 1), &row/1)

  # Zero based row index
  defp row(row), do: Enum.map(0..row, &binomial(row, &1))

  # Calculates the number at the given row and column (zero based indices)
  # using the binomial coefficients formula: n! / (k! * (n - k)!)
  defp binomial(n, k), do: factorial(n) / (factorial(k) * factorial(n - k))

  defp factorial(0), do: 1
  defp factorial(n) when n > 0, do: Enum.reduce(1..n, &*/2)
end
