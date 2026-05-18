defmodule CollatzConjecture do
  require Integer

  @doc """
  calc/1 takes an integer and returns the number of steps required to get the
  number to 1 when following the rules:
  - if number is odd, multiply with 3 and add 1
  - if number is even, divide by 2
  """
  @spec calc(integer() | {integer(), integer()}) :: integer() | {integer(), integer()}
  def calc(input)

  def calc({1, steps}), do: steps

  def calc({n, steps}) when Integer.is_even(n) do
    calc({Integer.floor_div(n, 2), steps + 1})
  end

  def calc({n, steps}) do
    calc({n * 3 + 1, steps + 1})
  end

  def calc(input) when is_integer(input) and input > 0 do
    calc({input, 0})
  end
end
