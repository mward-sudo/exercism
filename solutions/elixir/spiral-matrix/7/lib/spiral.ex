defmodule Spiral.Coord do
  @moduledoc """
  A struct representing a coordinate.
  """

  @enforce_keys [:x, :y]
  defstruct x: 0, y: 0

  @type t :: %__MODULE__{x: integer(), y: integer()}
  @type with_val :: {t(), integer()}

  @spec increment(t(), integer(), t()) :: t()
  def increment(%__MODULE__{x: x, y: y}, i, %__MODULE__{x: x_inc, y: y_inc}) do
    %__MODULE__{x: x + i * x_inc, y: y + i * y_inc}
  end
end

defmodule Spiral.Direction do
  @moduledoc """
  A struct representing the direction to move in.
  """
  alias Spiral.Coord

  @enforce_keys [:increment, :next]
  defstruct increment: nil, next: nil

  @type t :: %__MODULE__{increment: increment(), next: name()}
  @type name :: :right | :down | :left | :up
  @type increment :: Coord.t()

  @spec get(name()) :: t()
  def get(:right), do: %__MODULE__{increment: %Coord{x: 0, y: 1}, next: :down}
  def get(:down), do: %__MODULE__{increment: %Coord{x: 1, y: 0}, next: :left}
  def get(:left), do: %__MODULE__{increment: %Coord{x: 0, y: -1}, next: :up}
  def get(:up), do: %__MODULE__{increment: %Coord{x: -1, y: 0}, next: :right}
end

defmodule Spiral do
  @moduledoc """
  A module for generating a square matrix of numbers in clockwise spiral order from 0, 0.
  """

  @typep matrix :: [[integer()]]
  @typep spiral_accumulator :: {Coord.t(), Direction.t(), [Coord.t()]}

  alias Spiral.{Coord, Direction}

  @doc """
  Given the dimension, return a square matrix of numbers in clockwise spiral order.
  """
  @spec matrix(integer) :: matrix()
  def matrix(0), do: []

  def matrix(n) do
    coords_in_spiral_order(n)
    |> add_values_to_coords()
    |> convert_to_matrix(n)
  end

  @spec start_coord() :: Coord.t()
  defp start_coord(), do: %Coord{x: 1, y: 1}

  @spec coords_in_spiral_order(integer()) :: [Coord.t()]
  defp coords_in_spiral_order(n) do
    spiral_run_lengths(n)
    |> Enum.reduce({start_coord(), Direction.get(:right), []}, &spiral/2)
  end

  @spec spiral_run_lengths(integer()) :: [integer()]
  defp spiral_run_lengths(n) do
    # The first run is always n, then each run following
    # is n - 1, n - 1, n - 2, n - 2, etc. until we reach 1.
    # A zero is added to the end of the list to allow the
    # reduce function to terminate and return the correct final result.
    Enum.flat_map(n..0, &if(n == &1 or &1 == 0, do: [&1], else: [&1, &1]))
  end

  # Given a list of coordinates, add a value to each coordinate.
  # Co-ordinates should be supplied as a flat list, and in the order
  # they occur in the spiral. The value of the first coordinate will
  # be 1, the second 2, etc.
  @spec add_values_to_coords([Coord.t()]) :: [Coord.with_val()]
  defp add_values_to_coords(coords), do: Enum.with_index(coords, 1)

  # Takes a list of coordiantes with values, in the order they occur
  # in the spiral, and converts them to a matrix.
  # The matrix will be n x n, where n is the dimension of the spiral.
  @spec convert_to_matrix([Coord.with_val()], integer()) :: matrix()
  defp convert_to_matrix(coords_with_value, n) do
    coords_with_value
    |> Enum.sort()
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.chunk_every(n)
  end

  @spec spiral(integer(), spiral_accumulator()) :: spiral_accumulator() | [Coord.t()]
  defp spiral(0, {_, _, acc} = _acc), do: acc

  defp spiral(run_length, acc) do
    {
      initial_coord,
      %Direction{increment: increment_amount, next: next},
      coord_acc
    } = acc

    {
      Coord.increment(initial_coord, run_length, increment_amount),
      Direction.get(next),
      coord_acc ++ spiral_run(initial_coord, run_length, increment_amount)
    }
  end

  @spec spiral_run(Coord.t(), integer(), Direction.increment()) :: [Coord.t()]
  defp spiral_run(initial_coord, run_length, increment_amount) do
    Enum.map(
      1..run_length,
      &Coord.increment(initial_coord, &1, increment_amount)
    )
  end
end
