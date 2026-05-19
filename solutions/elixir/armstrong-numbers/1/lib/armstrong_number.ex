defmodule ArmstrongNumber do
  @moduledoc """
  Provides a way to validate whether or not a number is an Armstrong number
  """

  @spec valid?(integer) :: boolean
  def valid?(number) do
    digits = Integer.digits(number)

    digits
    |> Enum.map(fn digit -> digit ** length(digits) end)
    |> Enum.sum()
    |> Kernel.==(number)
  end
end
