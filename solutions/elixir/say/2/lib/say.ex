defmodule Say do
  @moduledoc """
  Translate a positive integer into English.
  """

  alias Say.Math

  @spec in_english(integer) :: {:ok | :error, String.t()}
  # We don't handle negative numbers
  def in_english(number) when number < 0, do: {:error, "number is out of range"}
  # When 0 is alone, it is spelled out
  def in_english(0), do: {:ok, "zero"}
  # We don't handle numbers greater than 999,999,999,999
  def in_english(number) when number >= 1_000_000_000_000, do: {:error, "number is out of range"}
  def in_english(number), do: {:ok, parse(number)}

  # Except when alone, 0 is not spelled out
  defp parse(0), do: ""
  # Numbers 1-15 are special cases
  defp parse(1), do: "one"
  defp parse(2), do: "two"
  defp parse(3), do: "three"
  defp parse(4), do: "four"
  defp parse(5), do: "five"
  defp parse(6), do: "six"
  defp parse(7), do: "seven"
  defp parse(8), do: "eight"
  defp parse(9), do: "nine"
  defp parse(10), do: "ten"
  defp parse(11), do: "eleven"
  defp parse(12), do: "twelve"
  defp parse(13), do: "thirteen"
  defp parse(14), do: "fourteen"
  defp parse(15), do: "fifteen"
  defp parse(18), do: "eighteen"
  # 16, 17 & 19 can be handled by removing the 10 and appending "teen"
  defp parse(number) when number in [16, 17, 19], do: parse(number - 10) <> "teen"
  # Tens from 20, 30, 40, 50 & 80 are special cases
  defp parse(20), do: "twenty"
  defp parse(30), do: "thirty"
  defp parse(40), do: "forty"
  defp parse(50), do: "fifty"
  defp parse(80), do: "eighty"
  # 60, 70 & 90 can be handled by dividing by 10 and appending "ty"
  defp parse(number) when number in [60, 70, 90] do
    {tens, _remainder} = Math.quotient_and_remainder(number, 10)
    parse(tens) <> "ty"
  end

  # Numbers under 100 not handled by the above
  defp parse(number) when number < 100 do
    {tens, remainder} = Math.quotient_and_remainder(number, 10)
    "#{parse(tens * 10)}-#{parse(remainder)}"
  end

  defp parse(number) when number < 1_000, do: format_number(number, 100, "hundred")

  defp parse(number) when number < 1_000_000, do: format_number(number, 1_000, "thousand")

  defp parse(number) when number < 1_000_000_000, do: format_number(number, 1_000_000, "million")

  defp parse(number) when number < 1_000_000_000_000,
    do: format_number(number, 1_000_000_000, "billion")

  defp format_number(number, divisor, unit) do
    {quotient, remainder} = Math.quotient_and_remainder(number, divisor)
    parsed_quotient = parse(quotient)
    parsed_remainder = parse(remainder)

    String.trim("#{parsed_quotient} #{unit} #{parsed_remainder}")
  end
end

defmodule Say.Math do
  @moduledoc """
  Math functions used by Say.
  """

  @spec quotient_and_remainder(integer, integer) :: {integer, integer}
  def quotient_and_remainder(number, divisor),
    do: {div(number, divisor), rem(number, divisor)}
end
