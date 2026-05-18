defmodule LineUp do
  @doc """
  Formats a full ticket sentence for the given name and number, including
  the person's name, the ordinal form of the number, and fixed descriptive text.
  """
  @spec format(name :: String.t(), number :: pos_integer()) :: String.t()
  def format(_, number) when number < 1 or number > 999,
    do: raise(ArgumentError, "number must be a positive integer between 1 and 999")

  def format(name, number),
    do:
      "#{name}, you are the #{number}#{ordinal_suffix(number)} customer we serve today. Thank you!"

  @spec ordinal_suffix(integer()) :: String.t()

  # Ensure the number is positive
  # Not strictly necessary for the solution, but helps to generalize the ordinal suffix function
  defp ordinal_suffix(num), do: num |> abs() |> do_ordinal_suffix()

  # Handle the special cases for 11, 12, and 13 first
  defp do_ordinal_suffix(num) when rem(num, 100) in 11..13, do: "th"
  # Handle the general cases for 1, 2, and 3
  defp do_ordinal_suffix(num) when rem(num, 10) == 1, do: "st"
  defp do_ordinal_suffix(num) when rem(num, 10) == 2, do: "nd"
  defp do_ordinal_suffix(num) when rem(num, 10) == 3, do: "rd"
  # Handle all other cases
  defp do_ordinal_suffix(_), do: "th"
end
