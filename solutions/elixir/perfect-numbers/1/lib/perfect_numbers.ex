defmodule PerfectNumbers do
  @doc """
  Determine the aliquot sum of the given `number`, by summing all the factors
  of `number`, aside from `number` itself.

  Based on this sum, classify the number as:

  :perfect if the aliquot sum is equal to `number`
  :abundant if the aliquot sum is greater than `number`
  :deficient if the aliquot sum is less than `number`
  """
  @spec classify(number :: integer) :: {:ok, atom} | {:error, String.t()}
  def classify(number) when number <= 0 do
    {:error, "Classification is only possible for natural numbers."}
  end

  def classify(number) do
    aliquot_sum = aliquot_sum(number)

    cond do
      aliquot_sum > number -> {:ok, :abundant}
      aliquot_sum < number -> {:ok, :deficient}
      aliquot_sum == number -> {:ok, :perfect}
    end
  end

  defp aliquot_sum(1), do: 0

  defp aliquot_sum(number) do
    # Biggest possible factor is half of the number
    1..div(number, 2)
    |> Enum.filter(fn x -> rem(number, x) == 0 end)
    |> Enum.sum()
  end
end
