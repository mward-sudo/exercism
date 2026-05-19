defmodule AllYourBase do
  # Must pass tests in ../test/all_your_base_test.exs

  @spec convert(digits :: list, input_base :: integer, output_base :: integer) ::
          {:ok, list} | {:error, String.t()}

  def convert(digits, input_base, output_base) do
    with :ok <- validate_bases(input_base, output_base),
         :ok <- validate_digits(digits, input_base),
         {:ok, number} <- convert_to_base_10(digits, input_base),
         {:ok, digits} <- convert_to_base(output_base, number) do
      {:ok, digits}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_bases(input_base, output_base) do
    cond do
      output_base < 2 -> {:error, "output base must be >= 2"}
      input_base < 2 -> {:error, "input base must be >= 2"}
      true -> :ok
    end
  end

  # Each element of the list must be an integer between 0 and input_base - 1
  defp validate_digits(digits, input_base) do
    if Enum.all?(digits, fn digit -> digit >= 0 and digit < input_base end) do
      :ok
    else
      {:error, "all digits must be >= 0 and < input base"}
    end
  end

  # Convert the list of digits to a base 10 number
  defp convert_to_base_10(digits, input_base) do
    digits =
      digits
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {digit, index}, acc ->
        acc + digit * input_base ** index
      end)

    {:ok, digits}
  end

  # Using recursion, convert the base 10 number to the output base
  defp convert_to_base(output_base, number) do
    if number == 0 do
      {:ok, [0]}
    else
      convert_to_base(output_base, number, [])
    end
  end

  defp convert_to_base(output_base, number, acc) do
    if number == 0 do
      {:ok, acc}
    else
      remainder = rem(number, output_base)
      quotient = div(number, output_base)
      convert_to_base(output_base, quotient, [remainder | acc])
    end
  end
end
