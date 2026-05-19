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
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    code
    |> Integer.digits(2)
    |> Enum.reverse()
    |> Stream.with_index()
    |> Stream.filter(fn {digit, _} -> digit == 1 end)
    |> Stream.map(fn {_, index} -> index end)
    |> Enum.map(fn index ->
      case index do
        0 -> "wink"
        1 -> "double blink"
        2 -> "close your eyes"
        3 -> "jump"
      end
    end)
  end
end
