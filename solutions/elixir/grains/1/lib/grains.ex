defmodule Grains do
  @chess_board_range 1..64

  @doc """
  Calculate two to the power of the input minus one.
  """
  @spec square(pos_integer()) :: {:ok, pos_integer()} | {:error, String.t()}
  def square(number) do
    case number in @chess_board_range do
      true ->
        {:ok, 2 ** (number - 1)}

      false ->
        {:error, "The requested square must be between 1 and 64 (inclusive)"}
    end
  end

  @doc """
  Adds square of each number from 1 to 64.
  """
  @spec total :: {:ok, pos_integer()}
  def total do
    sum =
      Enum.map(@chess_board_range, &square/1)
      |> Enum.map(fn {:ok, value} -> value end)
      |> Enum.sum()

    {:ok, sum}
  end
end
