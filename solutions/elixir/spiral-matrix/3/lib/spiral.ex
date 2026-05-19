defmodule Spiral do
  @directions %{
    right: %{increment: %{x: 0, y: 1}, next: :down},
    down: %{increment: %{x: 1, y: 0}, next: :left},
    left: %{increment: %{x: 0, y: -1}, next: :up},
    up: %{increment: %{x: -1, y: 0}, next: :right}
  }
  @initial {0, -1}

  @doc """
  Given the dimension, return a square matrix of numbers in clockwise spiral order.
  """
  @spec matrix(n :: integer) :: list(list(integer))
  def matrix(0), do: []

  def matrix(n) do
    coords_in_spiral_order(n)
    |> add_values_to_coords()
    |> convert_to_matrix(n)
  end

  defp coords_in_spiral_order(n) do
    spiral_run_lengths(n)
    |> Enum.reduce({@initial, @directions[:right], []}, &spiral/2)
  end

  defp spiral_run_lengths(n) do
    # The first run is always n, then each run following
    # is n - 1, n - 1, n - 2, n - 2, etc. until we reach 1.
    # A zero is added to the end of the list to allow the
    # reduce function to terminate and return the correct final result.
    Enum.flat_map(n..0, &if(n == &1 or &1 == 0, do: [&1], else: [&1, &1]))
  end

  defp add_values_to_coords(coords), do: Enum.with_index(coords, 1)

  defp convert_to_matrix(coords, n) do
    coords
    |> Enum.sort()
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.chunk_every(n)
  end

  defp spiral(0, {_, _, acc} = _acc), do: acc

  defp spiral(run_length, {initial, %{increment: increment, next: next}, acc} = _acc) do
    {
      increment(initial, run_length, increment),
      @directions[next],
      acc ++ side(initial, run_length, increment)
    }
  end

  defp side(initial, run_length, increment) do
    for i <- 1..run_length, do: increment(initial, i, increment)
  end

  defp increment({x, y}, i, %{x: 0} = increment), do: {x, y + i * increment.y}
  defp increment({x, y}, i, %{y: 0} = increment), do: {x + i * increment.x, y}
end
