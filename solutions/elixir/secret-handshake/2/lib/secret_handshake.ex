defmodule SecretHandshake do
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """

  @action_bits_indexes %{
    0 => "wink",
    1 => "double blink",
    2 => "close your eyes",
    3 => "jump",
    4 => "reverse"
  }

  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    code
    |> convert_integer_to_binary
    |> reverse
    |> convert_to_indexed_list
    |> assemble_actions_from_bits
    |> reverse_list_if_reverse_action_present
  end

  defp convert_integer_to_binary(code) do
    Integer.to_string(code, 2)
  end

  defp reverse(binary) do
    String.reverse(binary)
  end

  defp convert_to_indexed_list(binary_string) do
    binary_string
    |> String.codepoints()
    |> Enum.with_index()
  end

  defp assemble_actions_from_bits(binary_string) do
    binary_string
    |> filter_indexes_against_action_bits
    |> filter_set_bits
    |> create_list_of_actions_from_indexes
  end

  defp filter_indexes_against_action_bits(binary_string) do
    binary_string
    |> Enum.filter(fn {_, index} -> Map.has_key?(@action_bits_indexes, index) end)
  end

  defp filter_set_bits(binary_string) do
    binary_string
    |> Enum.filter(fn {bit, _} -> bit == "1" end)
  end

  defp create_list_of_actions_from_indexes(binary_string) do
    binary_string
    |> Enum.map(fn {_, index} -> @action_bits_indexes[index] end)
  end

  defp reverse_list_if_reverse_action_present(actions) do
    if Enum.member?(actions, "reverse") do
      actions
      |> Enum.reverse()
      |> Enum.filter(fn action -> action != "reverse" end)
    else
      actions
    end
  end
end
