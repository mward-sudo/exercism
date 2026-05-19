defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height

  Much faster than my previous iterations.
  Credit to angelikatyborska
  """
  @spec rows(integer) :: [[integer]]
  def rows(n) do
    Enum.map(1..n, &row/1)
  end

  defp row(1), do: [1]

  defp row(n) do
    [0 | row(n - 1)]
    |> Enum.chunk_every(2, 1, [0])
    |> Enum.map(&Enum.sum/1)
  end
end
