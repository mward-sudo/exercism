defmodule IsbnVerifier do
  @doc """
    Checks if a string is a valid ISBN-10 identifier

    ## Examples

      iex> IsbnVerifier.isbn?("3-598-21507-X")
      true

      iex> IsbnVerifier.isbn?("3-598-2K507-0")
      false

  """
  @spec isbn?(String.t()) :: boolean
  def isbn?(isbn) do
    isbn = normalise_isbn(isbn)

    String.match?(isbn, ~r/^[0-9]{9}[0-9X]$/) and valid_checksum?(isbn)
  end

  defp normalise_isbn(isbn) do
    isbn
    |> String.trim()
    |> String.replace("-", "")
  end

  defp valid_checksum?(isbn) do
    isbn
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn
      {"X", 9} -> 10 * (10 - 9)
      {char, index} -> String.to_integer(char) * (10 - index)
    end)
    |> Enum.sum()
    |> rem(11)
    |> Kernel.==(0)
  end
end
