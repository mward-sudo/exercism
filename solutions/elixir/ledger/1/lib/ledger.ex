defmodule Ledger do
  @moduledoc """
  A ledger printer that formats financial entries into a table.

  This module has been refactored for better readability, maintainability, and idiomatic Elixir usage.
  Key changes:
  - Extracted formatting logic into separate named functions for date, description, amount, and number.
  - Simplified sorting using Enum.sort_by with a tuple key instead of a custom comparator.
  - Added type specifications for all functions.
  - Removed code duplication in number formatting by parameterizing separators.
  - Used pattern matching in function clauses for header selection, date formatting, and conditional logic.
  - Replaced if statements with guards, case expressions, and function clauses where appropriate.
  - Extracted multiline case clauses into separate functions for cleaner case statements.
  - Improved readability by breaking down complex expressions into smaller, named functions.
  """

  @doc """
  Format the given entries given a currency and locale
  """
  @type currency :: :usd | :eur
  @type locale :: :en_US | :nl_NL
  @type entry :: %{amount_in_cents: integer(), date: Date.t(), description: String.t()}

  @spec format_entries(currency(), locale(), list(entry())) :: String.t()
  def format_entries(currency, locale, entries) do
    header = get_header(locale)

    case entries do
      [] -> header
      _ -> format_non_empty_entries(entries, header, currency, locale)
    end
  end

  @spec format_non_empty_entries(list(entry()), String.t(), currency(), locale()) :: String.t()
  defp format_non_empty_entries(entries, header, currency, locale) do
    formatted_entries =
      entries
      |> sort_entries()
      |> Enum.map_join("\n", &format_entry(&1, currency, locale))

    header <> formatted_entries <> "\n"
  end

  @spec sort_entries(list(entry())) :: list(entry())
  defp sort_entries(entries) do
    Enum.sort_by(entries, &{&1.date, &1.description, &1.amount_in_cents})
  end

  @spec format_entry(entry(), currency(), locale()) :: String.t()
  defp format_entry(entry, currency, locale) do
    date_str = format_date(entry.date, locale)
    desc_str = format_description(entry.description)
    amount_str = format_amount(entry.amount_in_cents, currency, locale)
    "#{date_str}|#{desc_str} |#{amount_str}"
  end

  @spec get_header(locale()) :: String.t()
  defp get_header(:en_US), do: "Date       | Description               | Change       \n"
  defp get_header(:nl_NL), do: "Datum      | Omschrijving              | Verandering  \n"

  @spec format_date(Date.t(), locale()) :: String.t()
  defp format_date(date, :en_US) do
    month = String.pad_leading(to_string(date.month), 2, "0")
    day = String.pad_leading(to_string(date.day), 2, "0")
    year = to_string(date.year)
    "#{month}/#{day}/#{year} "
  end

  defp format_date(date, :nl_NL) do
    day = String.pad_leading(to_string(date.day), 2, "0")
    month = String.pad_leading(to_string(date.month), 2, "0")
    year = to_string(date.year)
    "#{day}-#{month}-#{year} "
  end

  @spec format_description(String.t()) :: String.t()
  defp format_description(description) when byte_size(description) > 25 do
    " " <> String.slice(description, 0, 22) <> "..."
  end

  defp format_description(description) do
    " " <> String.pad_trailing(description, 25, " ")
  end

  @spec format_number(integer(), String.t(), String.t()) :: String.t()
  defp format_number(cents, _thousands_sep, decimal_sep) when div(abs(cents), 100) < 1000 do
    abs_cents = abs(cents)
    decimal = rem(abs_cents, 100) |> to_string() |> String.pad_leading(2, "0")
    whole = div(abs_cents, 100)
    to_string(whole) <> decimal_sep <> decimal
  end

  defp format_number(cents, thousands_sep, decimal_sep) do
    abs_cents = abs(cents)
    decimal = rem(abs_cents, 100) |> to_string() |> String.pad_leading(2, "0")
    whole = div(abs_cents, 100)
    thousands = div(whole, 1000)
    remainder = rem(whole, 1000)
    to_string(thousands) <> thousands_sep <> to_string(remainder) <> decimal_sep <> decimal
  end

  @spec format_amount(integer(), currency(), locale()) :: String.t()
  defp format_amount(cents, currency, locale) do
    symbol = currency_symbol(currency)
    {thousands_sep, decimal_sep} = separators(locale)
    number = format_number(cents, thousands_sep, decimal_sep)

    formatted =
      case {cents >= 0, locale} do
        {true, :en_US} -> "  #{symbol}#{number} "
        {true, :nl_NL} -> " #{symbol} #{number} "
        {false, :en_US} -> " (#{symbol}#{number})"
        {false, :nl_NL} -> " #{symbol} -#{number} "
      end

    String.pad_leading(formatted, 14, " ")
  end

  @spec separators(locale()) :: {String.t(), String.t()}
  defp separators(:en_US), do: {",", "."}
  defp separators(:nl_NL), do: {".", ","}

  @spec currency_symbol(currency()) :: String.t()
  defp currency_symbol(:eur), do: "€"
  defp currency_symbol(:usd), do: "$"
end
