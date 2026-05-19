defmodule CryptoSquare do
  @doc """
  Encode string square methods
  ## Examples

    iex> CryptoSquare.encode("abcd")
    "ac bd"
  """
  @spec encode(String.t()) :: String.t()
  def encode(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "")
    |> encode_string()
  end

  defp encode_string(""), do: ""

  defp encode_string(str) do
    columns = calculate_columns(str)

    String.graphemes(str)
    |> Enum.chunk_every(columns)
    |> Enum.map(fn
      chunk when length(chunk) < columns -> chunk ++ List.duplicate(" ", columns - length(chunk))
      chunk -> chunk
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join(" ")
  end

  defp calculate_columns(str) do
    String.length(str)
    |> :math.sqrt()
    |> ceil()
  end
end
