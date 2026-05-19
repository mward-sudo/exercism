defmodule Triangle do
  @type kind :: :equilateral | :isosceles | :scalene

  @doc """
  Return the kind of triangle of a triangle with 'a', 'b' and 'c' as lengths.
  """
  @spec kind(number, number, number) :: {:ok, kind} | {:error, String.t()}
  def kind(a, a, a) when a > 0, do: {:ok, :equilateral}

  def kind(a, b, c) do
    with :ok <- validate_triangle(a, b, c),
         {:ok, kind} <- kind({a, b, c}) do
      {:ok, kind}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp kind({a, b, c}) do
    case isoscelese?(a, b, c) do
      true -> {:ok, :isosceles}
      _ -> {:ok, :scalene}
    end
  end

  defp validate_triangle(a, b, c) do
    with :ok <- validate_lengths_above_zero(a, b, c),
         :ok <- validate_lengths(a, b, c) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_lengths_above_zero(a, b, c) do
    case lengths_above_zero?([a, b, c]) do
      true -> :ok
      _ -> {:error, "all side lengths must be positive"}
    end
  end

  defp validate_lengths(a, b, c) do
    case valid_side_lengths?(a, b, c) do
      true -> :ok
      _ -> {:error, "side lengths violate triangle inequality"}
    end
  end

  # Boolean tests
  defp lengths_above_zero?(nums), do: Enum.all?(nums, &(&1 > 0))
  defp valid_side_lengths?(a, b, c), do: a + b >= c and a + c >= b and b + c >= a
  defp isoscelese?(a, b, c), do: Enum.uniq([a, b, c]) |> Enum.count() == 2
end
