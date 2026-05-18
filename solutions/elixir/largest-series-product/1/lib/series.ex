defmodule Series do
  @doc """
  Finds the largest product of a given number of consecutive numbers in a given string of numbers.
  """
  @spec largest_product(String.t(), non_neg_integer) :: non_neg_integer
  def largest_product("", size)
      when size > 0,
      do: raise(ArgumentError, "Span size is too large")

  def largest_product(_number_string, size)
      when size < 0,
      do: raise(ArgumentError, "Span size is too small")

  def largest_product(_number_string, 0), do: 1

  def largest_product(number_string, size) do
    number_string
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> find_largest_product(size)
  end

  defp find_largest_product(number_list, size)
       when size > length(number_list),
       do: raise(ArgumentError, "Span size is too large")

  defp find_largest_product(number_list, size) do
    number_list
    |> Enum.chunk_every(size, 1, :discard)
    |> Enum.map(&Enum.reduce(&1, fn x, acc -> x * acc end))
    |> Enum.max()
  end
end
