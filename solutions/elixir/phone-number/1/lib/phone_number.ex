defmodule PhoneNumber do
  @errors %{
    incorrect_number_of_digits: "incorrect number of digits",
    must_contain_digits_only: "must contain digits only",
    area_code_cannot_start_with_zero: "area code cannot start with zero",
    area_code_cannot_start_with_one: "area code cannot start with one",
    exchange_code_cannot_start_with_zero: "exchange code cannot start with zero",
    exchange_code_cannot_start_with_one: "exchange code cannot start with one",
    eleven_digits_must_start_with_one: "11 digits must start with 1"
  }

  @doc """
  Remove formatting from a phone number if the given number is valid. Return an error otherwise.
  """
  @spec clean(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def clean(raw) do
    with :ok <- validate_characters(raw),
         digits_only <- clean_raw_string(raw),
         :ok <- must_be_correct_length(digits_only),
         {:ok, ten_digits} <- validate_country_code(digits_only),
         :ok <- validate_area_code(ten_digits),
         :ok <- validate_exchange_code(ten_digits) do
      {:ok, ten_digits}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec validate_characters(String.t()) :: :ok | {:error, String.t()}
  defp validate_characters(raw) do
    # Seperators include spaces, hyphens, periods, plus sign and parentheses
    if String.match?(raw, ~r/^[0-9\-\s\.\(\)\+]+$/) do
      :ok
    else
      {:error, @errors.must_contain_digits_only}
    end
  end

  @spec clean_raw_string(String.t()) :: String.t()
  defp clean_raw_string(raw), do: String.replace(raw, ~r/[^0-9]/, "")

  @spec must_be_correct_length(String.t()) :: :ok | {:error, String.t()}
  defp must_be_correct_length(numbers) do
    case String.length(numbers) do
      10 -> :ok
      11 -> :ok
      _ -> {:error, @errors.incorrect_number_of_digits}
    end
  end

  @spec validate_country_code(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_country_code(number) do
    case String.length(number) do
      10 -> {:ok, number}
      11 -> country_code_is_one(number)
    end
  end

  @spec country_code_is_one(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp country_code_is_one(digits) do
    case String.at(digits, 0) do
      "1" -> {:ok, String.slice(digits, 1..-1)}
      _ -> {:error, @errors.eleven_digits_must_start_with_one}
    end
  end

  @spec validate_area_code(String.t()) :: :ok | {:error, String.t()}
  defp validate_area_code(digits) do
    case String.at(digits, 0) do
      "0" <> _ -> {:error, @errors.area_code_cannot_start_with_zero}
      "1" <> _ -> {:error, @errors.area_code_cannot_start_with_one}
      _ -> :ok
    end
  end

  @spec validate_exchange_code(String.t()) :: :ok | {:error, String.t()}
  defp validate_exchange_code(digits) do
    case String.at(digits, 3) do
      "0" <> _ -> {:error, @errors.exchange_code_cannot_start_with_zero}
      "1" <> _ -> {:error, @errors.exchange_code_cannot_start_with_one}
      _ -> :ok
    end
  end
end
