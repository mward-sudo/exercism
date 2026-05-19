defmodule Spiral do
  @type coord :: {integer(), integer()}
  @type coord_with_value :: {coord(), integer()}
  @type direction :: :right | :down | :left | :up
  @type increment :: %{x: integer(), y: integer()}
  @type matrix :: [[integer()]]
  @type spiral_accumulator :: {coord(), %{increment: increment(), next: direction}, [coord()]}

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
  @spec matrix(n :: integer) :: matrix()
  def matrix(0), do: []

  def matrix(n) do
    coords_in_spiral_order(n)
    |> add_values_to_coords()
    |> convert_to_matrix(n)
  end

  @spec coords_in_spiral_order(n :: integer()) :: [coord()]
  defp coords_in_spiral_order(n) do
    spiral_run_lengths(n)
    |> Enum.reduce({@initial, @directions[:right], []}, &spiral/2)
  end

  @spec spiral_run_lengths(n :: integer()) :: [integer()]
  defp spiral_run_lengths(n) do
    # The first run is always n, then each run following
    # is n - 1, n - 1, n - 2, n - 2, etc. until we reach 1.
    # A zero is added to the end of the list to allow the
    # reduce function to terminate and return the correct final result.
    Enum.flat_map(n..0, &if(n == &1 or &1 == 0, do: [&1], else: [&1, &1]))
  end

  @spec add_values_to_coords(coords :: [coord()]) :: [coord_with_value()]
  defp add_values_to_coords(coords), do: Enum.with_index(coords, 1)

  @spec convert_to_matrix(coords_with_value :: [coord_with_value()], n :: integer()) :: matrix()
  defp convert_to_matrix(coords_with_value, n) do
    coords_with_value
    |> Enum.sort()
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.chunk_every(n)
  end

  @spec spiral(run_length :: integer(), _acc :: spiral_accumulator()) ::
          spiral_accumulator() | [coord()]
  defp spiral(0, {_, _, acc} = _acc), do: acc

  defp spiral(run_length, {initial, %{increment: increment, next: next}, acc} = _acc) do
    {
      increment(initial, run_length, increment),
      @directions[next],
      acc ++ side(initial, run_length, increment)
    }
  end

  @spec side(initial :: coord(), run_length :: integer(), increment :: increment()) :: [coord()]
  defp side(initial, run_length, increment) do
    for i <- 1..run_length, do: increment(initial, i, increment)
  end

  @spec increment(initial :: coord(), i :: integer(), increment :: increment()) :: coord()
  defp increment({x, y}, i, %{x: 0} = increment), do: {x, y + i * increment.y}
  defp increment({x, y}, i, %{y: 0} = increment), do: {x + i * increment.x, y}
end
