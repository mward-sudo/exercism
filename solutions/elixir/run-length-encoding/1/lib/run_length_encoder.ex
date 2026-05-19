defmodule RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "AABBBCCCC" => "2A3B4C"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "2A3B4C" => "AABBBCCCC"
  """
  @spec encode(String.t()) :: String.t()
  def encode(string) do
    string
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.reduce([], fn
      x, [head = [h | _] | tail] when x == h -> [[x | head] | tail]
      x, acc -> [[x] | acc]
    end)
    |> Enum.map(fn
      group when length(group) > 1 -> "#{Enum.count(group)}#{Enum.at(group, 0)}"
      group -> Enum.at(group, 0)
    end)
    |> Enum.join()
  end

  @doc """
  Decodes a string that has been encoded with the encode function.

  # Examples
  iex> RunLengthEncoder.decode("2A3B4C")
  "AABBBCCCC"
  """
  @spec decode(String.t()) :: String.t()
  def decode(string) do
    Regex.scan(~r/(\d*)([A-Za-z ])/, string, capture: :all_but_first)
    |> Enum.reduce("", fn
      ["", letter], acc -> acc <> letter
      [number, letter], acc -> acc <> String.duplicate(letter, String.to_integer(number))
    end)
  end
end
