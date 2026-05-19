defmodule SimpleCipher do
  @moduledoc """
  Simple Cipher
  """

  @doc """
  Given a `plaintext` and `key`, encode each character of the `plaintext` by
  shifting it by the corresponding letter in the alphabet shifted by the number
  of letters represented by the `key` character, repeating the `key` if it is
  shorter than the `plaintext`.

  For example, for the letter 'd', the alphabet is rotated to become:

  defghijklmnopqrstuvwxyzabc

  You would encode the `plaintext` by taking the current letter and mapping it
  to the letter in the same position in this rotated alphabet.

  abcdefghijklmnopqrstuvwxyz
  defghijklmnopqrstuvwxyzabc

  "a" becomes "d", "t" becomes "w", etc...

  Each letter in the `plaintext` will be encoded with the alphabet of the `key`
  character in the same position. If the `key` is shorter than the `plaintext`,
  repeat the `key`.

  Example:

  plaintext = "testing"
  key = "abc"

  The key should repeat to become the same length as the text, becoming
  "abcabca". If the key is longer than the text, only use as many letters of it
  as are necessary.
  """
  @spec encode(binary, binary, keyword) :: any
  def encode(plaintext, key \\ "") do
    key =
      case key do
        "" -> plaintext |> String.length() |> generate_key()
        _ -> key
      end

    encode(plaintext, key, reverse_shift?: false)
  end

  defp encode(plaintext, key, opts) do
    reverse_shift? = Keyword.get(opts, :reverse_shift?)

    plaintext
    |> String.to_charlist()
    |> Enum.zip(normalize_key(plaintext, key))
    |> Enum.map(&shift_char(&1, reverse_shift?: reverse_shift?))
    |> to_string()
  end

  @doc """
  Given a `ciphertext` and `key`, decode each character of the `ciphertext` by
  finding the corresponding letter in the alphabet shifted by the number of
  letters represented by the `key` character, repeating the `key` if it is
  shorter than the `ciphertext`.

  The same rules for key length and shifted alphabets apply as in `encode/2`,
  but you will go the opposite way, so "d" becomes "a", "w" becomes "t",
  etc..., depending on how much you shift the alphabet.
  """
  @spec decode(binary, binary) :: binary
  def decode(ciphertext, key), do: encode(ciphertext, key, reverse_shift?: true)

  @doc """
  Generate a random key of a given length. It should contain lowercase letters only.
  """
  def generate_key(length) do
    1..length
    |> Enum.map(fn _ -> :rand.uniform(26) + ?a - 1 end)
    |> to_string()
  end

  defp normalize_key(plaintext, key) do
    plaintext_length = String.length(plaintext)

    case String.length(key) do
      key_length when key_length > plaintext_length ->
        String.slice(key, 0, plaintext_length)

      key_length when key_length < plaintext_length ->
        lengthen_key(plaintext_length, key)

      _ ->
        key
    end
    |> String.to_charlist()
  end

  defp lengthen_key(desired_length, key) do
    key_length = String.length(key)

    repeat = div(desired_length, key_length) + 1

    String.duplicate(key, repeat)
    |> String.slice(0, desired_length)
  end

  defp shift_char({plaintext_char, key_char}, opts) do
    shift_amount =
      case Keyword.get(opts, :reverse_shift?) do
        true -> -1 * char_to_shift_amount(key_char)
        false -> char_to_shift_amount(key_char)
      end

    shift_char_by_amount(plaintext_char, shift_amount)
  end

  defp char_to_shift_amount(char), do: char - ?a

  defp shift_char_by_amount(char, shift_amount) do
    [rem(char - ?a + shift_amount + 26, 26) + ?a]
  end
end
