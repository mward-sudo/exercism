defmodule Say do
  @moduledoc """
  Translate a positive integer into English.
  """

  @one_trillion 1_000_000_000_000
  @one_billion 1_000_000_000

  @numbers %{
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five",
    6 => "six",
    7 => "seven",
    8 => "eight",
    9 => "nine",
    10 => "ten",
    11 => "eleven",
    12 => "twelve",
    13 => "thirteen",
    14 => "fourteen",
    15 => "fifteen",
    16 => "sixteen",
    17 => "seventeen",
    18 => "eighteen",
    19 => "nineteen",
    20 => "twenty",
    30 => "thirty",
    40 => "forty",
    50 => "fifty",
    60 => "sixty",
    70 => "seventy",
    80 => "eighty",
    90 => "ninety",
    100 => "hundred"
  }

  @spec in_english(integer) :: {atom, String.t()}
  # We can't handle negative numbers or numbers above 999,999,999,999
  def in_english(number) when number < 0 or number >= @one_trillion,
    do: {:error, "number is out of range"}

  # We can handle zero, but it's a special case
  def in_english(0), do: {:ok, "zero"}

  # All other numbers are handled by the parse/1 function
  def in_english(number), do: {:ok, parse(number)}

  # Start the parse with an empty accumulator
  # and the number to be parsed, return the first element
  defp parse(number), do: parse([], number) |> Enum.at(0)

  defp parse([], 0), do: nil
  # All numbers below 20 are unique, so we can just return them
  defp parse(acc, number) when number <= 20, do: acc ++ [@numbers[number]]

  # Numbers 20-99 are slightly different to numbers above 100
  defp parse(acc, number) when number < 100 do
    acc ++
      [
        [
          @numbers[div(number, 10) * 10],
          @numbers[rem(number, 10)]
        ]
        |> Enum.filter(&(&1 != nil))
        |> Enum.join("-")
      ]
  end

  # Numbers above 100 have a consistent pattern
  defp parse(acc, number) do
    case number do
      number when number < 1_000 ->
        parse(acc, number, 100, "hundred")

      number when number < 1_000_000 ->
        parse(acc, number, 1_000, "thousand")

      number when number < @one_billion ->
        parse(acc, number, 1_000_000, "million")

      number when number < @one_trillion ->
        parse(acc, number, @one_billion, "billion")
    end
  end

  defp parse(acc, number, unit_value, unit_name) do
    acc ++
      [
        [
          parse([], div(number, unit_value)),
          unit_name,
          parse([], rem(number, unit_value))
        ]
        |> Enum.filter(&(&1 != nil))
        |> Enum.join(" ")
      ]
  end
end
