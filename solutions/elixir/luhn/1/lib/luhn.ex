defmodule Luhn do
  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) when is_binary(number) do
    with number_without_spaces <- String.replace(number, ~r/\s/, ""),
         {:ok, valid_number} <- validate_string_format(number_without_spaces),
         digits <- binary_to_digits(valid_number) do
      checksum(digits) == 0
    else
      _ -> false
    end
  end

  def valid?(_), do: false

  defp validate_string_format(number) do
    with {_, ""} <- Integer.parse(number),
         true <- String.length(number) > 1 do
      {:ok, number}
    else
      _ -> {:error, :invalid_number}
    end
  end

  defp binary_to_digits(number) do
    number
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp checksum(number) do
    number
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(&calculate_digit_value/1)
    |> Enum.sum()
    |> get_rem(10)
  end

  defp calculate_digit_value({digit, index}) when index == 0 or rem(index, 2) == 0, do: digit

  defp calculate_digit_value({digit, _}) do
    (digit * 2) |> handle_double_digits()
  end

  defp handle_double_digits(number) when number > 9, do: number - 9
  defp handle_double_digits(number), do: number

  defp get_rem(0, _), do: 0
  defp get_rem(number, divisor), do: rem(number, divisor)
end
