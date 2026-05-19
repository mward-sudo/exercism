defmodule GameOfLife do
  @doc """
  Apply the rules of Conway's Game of Life to a grid of cells
  """

  @spec tick(matrix :: list(list(0 | 1))) :: list(list(0 | 1))
  def tick([]), do: []

  def tick(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, col_index} ->
        apply_rules(cell, count_live_neighbors(matrix, row_index, col_index))
      end)
    end)
  end

  defp apply_rules(cell, live_neighbors) do
    case {cell, live_neighbors} do
      {1, 2} -> 1
      {1, 3} -> 1
      {0, 3} -> 1
      _ -> 0
    end
  end

  defp count_live_neighbors(matrix, row_index, col_index) do
    neighbor_positions(row_index, col_index)
    |> Enum.count(fn {r, c} -> get_cell(matrix, r, c) == 1 end)
  end

  defp neighbor_positions(row_index, col_index) do
    for row_offset <- -1..1,
        col_offset <- -1..1,
        {row_offset, col_offset} != {0, 0} do
      {row_index + row_offset, col_index + col_offset}
    end
  end

  defp get_cell(_matrix, row, col) when row < 0 or col < 0, do: 0

  defp get_cell(matrix, row, col) do
    matrix
    |> Enum.at(row, [])
    |> Enum.at(col, 0)
  end
end
