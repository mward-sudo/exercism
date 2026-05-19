defmodule DNA do
  @dna_codes %{
    ?\s => 0b0000,
    ?A => 0b0001,
    ?C => 0b0010,
    ?G => 0b0100,
    ?T => 0b1000
  }

  def encode_nucleotide(code_point) do
    Map.get(@dna_codes, code_point)
  end

  def decode_nucleotide(encoded_code) do
    Enum.find(@dna_codes, fn {_key, val} -> val == encoded_code end)
    |> elem(0)
  end

  def encode([]), do: <<>>

  def encode([head | tail]) do
    <<(<<encode_nucleotide(head)::4>>)::bitstring, encode(tail)::bitstring>>
  end

  def decode("") do
    ''
  end

  def decode(<<value::4, rest::bitstring>>) do
    [decode_nucleotide(value)] ++ decode(rest)
  end
end
