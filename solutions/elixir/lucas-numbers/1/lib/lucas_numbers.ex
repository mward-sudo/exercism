defmodule LucasNumbers do
  @moduledoc """
  Lucas numbers are an infinite sequence of numbers which build progressively
  which hold a strong correlation to the golden ratio (φ or ϕ)

  E.g.: 2, 1, 3, 4, 7, 11, 18, 29, ...
  """

  def generate(count) when is_integer(count) and count > 0 do
    # This looks like an infinite loop on the Stream.unfold() method, but it's not.
    # The Stream.unfold() method is a lazy infinite stream generator.
    # It will only generate the next element in the stream when it's needed.
    # The Enum.take() effectively forces the stream to be evaluated to the limit of count.
    Stream.unfold({2, 1}, fn {a, b} -> {a, {b, a + b}} end)
    |> Enum.take(count)
  end

  def generate(_), do: raise(ArgumentError, "count must be specified as an integer >= 1")
end
