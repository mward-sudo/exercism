defmodule PhoneNumber do
  @moduledoc """
  Clean up user-entered phone numbers so that they can be sent SMS messages.
  """

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
    with {:ok, digits} <- clean_raw_string(raw),
         {:ok, _digits} <- validate_code_digits(digits) do
      {:ok, digits}
    end
  end

  @spec clean_raw_string(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp clean_raw_string(raw) do
    case String.match?(raw, ~r/^[0-9\-\s\.\(\)\+]+$/) do
      true -> raw |> digits_only() |> correct_length()
      false -> {:error, @errors.must_contain_digits_only}
    end
  end

  @spec digits_only(String.t()) :: String.t()
  defp digits_only(raw), do: String.replace(raw, ~r/[^0-9]/, "")

  @spec correct_length(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp correct_length(digits) do
    case String.length(digits) do
      10 -> {:ok, digits}
      11 -> validate_country_code(digits)
      _ -> {:error, @errors.incorrect_number_of_digits}
    end
  end

  @spec validate_country_code(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_country_code(digits) do
    case String.at(digits, 0) do
      "1" -> {:ok, String.slice(digits, 1..-1)}
      _ -> {:error, @errors.eleven_digits_must_start_with_one}
    end
  end

  @spec validate_code_digits(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_code_digits(digits) do
    with :ok <- validate_area_code(digits),
         :ok <- validate_exchange_code(digits) do
      {:ok, digits}
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
