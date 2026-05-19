defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(num), do: for(row <- 1..num, do: row(row))

  defp row(row), do: for(col <- 1..row, do: number({row, col}))

  defp number({row, col}),
    do: div(factorial(row - 1), factorial(col - 1) * factorial(row - col))

  defp factorial(0), do: 1
  defp factorial(n) when n > 0, do: n * factorial(n - 1)
end
