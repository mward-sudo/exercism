defmodule SquareRoot do
  @doc """
  Calculate the integer square root of a positive integer
  """
  @spec calculate(radicand :: pos_integer) :: pos_integer
  def calculate(radicand) do
    do_calculate(radicand, 0, radicand)
  end

  defp do_calculate(radicand, low, high) when low <= high do
    mid = div(low + high, 2)
    square = mid * mid

    cond do
      square == radicand ->
        mid

      square > radicand ->
        do_calculate(radicand, low, mid - 1)

      square < radicand ->
        if (mid + 1) * (mid + 1) > radicand, do: mid, else: do_calculate(radicand, mid + 1, high)
    end
  end
end
