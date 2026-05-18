defmodule ArmstrongNumber do
  @moduledoc """
  Provides a way to validate whether or not a number is an Armstrong number
  """

  @spec valid?(integer) :: boolean
  def valid?(number) do
    digits = Integer.digits(number)
    exp = length(digits)

    sum =
      digits
      |> Enum.map(&(&1 ** exp))
      |> Enum.sum()

    sum == number
  end
end
