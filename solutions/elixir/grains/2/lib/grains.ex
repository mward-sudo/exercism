defmodule Grains do
  @chess_board_range 1..64

  @doc """
  Calculate two to the power of the input minus one.
  """
  @spec square(pos_integer()) :: {:ok, pos_integer()} | {:error, String.t()}
  def square(number)
      when number in @chess_board_range,
      do: {:ok, 2 ** (number - 1)}

  def square(_),
    do: {:error, "The requested square must be between 1 and 64 (inclusive)"}

  defp square!(number) do
    case square(number) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
  Adds square of each number from 1 to 64.
  """
  @spec total :: {:ok, pos_integer()}
  def total do
    {:ok, total!()}
  end

  defp total! do
    Enum.reduce(@chess_board_range, 0, &(square!(&1) + &2))
  end
end
