defmodule RotationalCipher do
  @lowercase ?a..?z
  @uppercase ?A..?Z

  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    text
    |> String.to_charlist()
    |> Enum.map(&rotate_char(&1, shift))
    |> to_string()
  end

  @spec rotate_char(char :: char(), shift :: integer) :: char()
  defp rotate_char(char, shift)
       when char in @lowercase,
       do: rotate_char(char, shift, ?z)

  defp rotate_char(char, shift)
       when char in @uppercase,
       do: rotate_char(char, shift, ?Z)

  defp rotate_char(char, _shift), do: char

  @spec rotate_char(char :: char(), shift :: integer(), upper_bound :: char()) :: char()
  defp rotate_char(char, shift, upper_bound)
       when char + shift > upper_bound,
       do: char + shift - 26

  defp rotate_char(char, shift, _upper_bound), do: char + shift
end
