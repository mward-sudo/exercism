defmodule AffineCipher.EncodeKey do
  @moduledoc """
  A module for creating a key for encoding an affine cipher.
  """

  defstruct a: 0, b: 0, m: 0

  @typedoc """
  A type for the encryption key
  """
  @type t :: %__MODULE__{a: integer(), b: integer(), m: pos_integer()}

  @doc """
  Create a key for encryption and decryption

  `a` and `b` are integers, and `a` and `m` must be coprime where `m` is the length
  of the alphabet - that is the only common factor shared between a and m is one.

  `m` defaults to 26, the number of letters in the roman alphabet.
  """
  @spec new(a :: integer(), b :: integer(), m :: pos_integer()) ::
          {:ok, t()} | {:error, String.t()}
  def new(a, b, m \\ 26) do
    case coprime?(a, m) do
      true -> {:ok, %__MODULE__{a: a, b: b, m: m}}
      false -> {:error, "a and m must be coprime."}
    end
  end

  defp coprime?(a, b), do: Integer.gcd(a, b) == 1
end

defmodule AffineCipher.DecodeKey do
  @moduledoc """
  A module for creating a key for decoding an affine cipher.
  """

  defstruct a: 0, b: 0, m: 0

  @typedoc """
  A type for the encryption key
  """
  @type t :: %__MODULE__{a: integer(), b: integer(), m: pos_integer()}

  @doc """
  Create a key for encryption and decryption

  `a` and `b` are integers, and `a` and `m` must be coprime where `m` is the length
  of the alphabet - that is the only common factor shared between a and m is one.

  `m` defaults to 26, the number of letters in the roman alphabet.

  Returns a tuple of `{:ok, key}` or `{:error, message}`
  For key.a the modular multiplicative inverse of a is returned, as
  required for decryption.

  ## Examples

      iex> AffineCipher.DecodeKey.new(3, 7)
      {:ok, %AffineCipher.DecodeKey{a: 9, b: 7, m: 26}}

      iex> AffineCipher.DecodeKey.new(3, 7, 32)
      {:ok, %AffineCipher.DecodeKey{a: 11, b: 7, m: 32}}

      iex> AffineCipher.DecodeKey.new(26, 7)
      {:error, "a and m must be coprime."}
  """
  @spec new(a :: integer(), b :: integer(), m :: pos_integer()) ::
          {:ok, t()} | {:error, String.t()}
  def new(a, b, m \\ 26) do
    case Integer.extended_gcd(a, m) do
      {1, inv_a, _} -> {:ok, %__MODULE__{a: inv_a, b: b, m: m}}
      _ -> {:error, "a and m must be coprime."}
    end
  end
end

defmodule AffineCipher do
  @moduledoc """
  An implementation of the Affine Cipher.
  """

  alias AffineCipher.{Chars, Decoder, Encoder}

  @typedoc """
  A type for the encryption key
  """
  @type key() :: %{a: integer, b: integer}

  @doc """
  Encode an encrypted message using a key

  See `AffineCipher.decode/2` for more information on the key.
  """
  @spec encode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(key, message), do: Encoder.encode(key, message)

  @doc """
  Decode an encrypted message using a key.

  See `AffineCipher.decode/2` for more information on the key.
  """
  @spec decode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(key, cipher), do: Decoder.decode(key, cipher)
end

defmodule AffineCipher.Chars do
  @moduledoc """
  A module for working with characters in the affine cipher.
  """

  @typedoc """
  Character values for lowercase letters
  """
  @type lowercase_chars :: ?a..?z

  @typedoc """
  Character values for digits
  """
  @type digits :: ?0..?9

  @typedoc """
  Character values for valid characters (digits and lowercase letters)
  """
  @type valid_chars :: lowercase_chars() | digits()

  @typedoc """
  Index values for lowercase letters
  """
  @type index :: 0..25

  @doc """
  Convert a lowercase character to an index

  ## Examples
      iex> AffineCipher.Chars.char_to_index(?a)
      0

      iex> AffineCipher.Chars.char_to_index(?m)
      12

      iex> AffineCipher.Chars.char_to_index(?z)
      25
  """
  @spec char_to_index(char :: lowercase_chars()) :: index()
  def char_to_index(char) when char in ?a..?z, do: char - ?a

  @doc """
  Convert an index to a lowercase character

  ## Examples
      iex> AffineCipher.Chars.index_to_char(0)
      ?a

      iex> AffineCipher.Chars.index_to_char(12)
      ?m

      iex> AffineCipher.Chars.index_to_char(25)
      ?z
  """
  @spec index_to_char(index :: index()) :: lowercase_chars()
  def index_to_char(index) when index in 0..25, do: index + ?a
end

defmodule AffineCipher.Encoder do
  @moduledoc """
  A module for encoding a message using an affine cipher.
  """

  alias AffineCipher.{Chars, EncodeKey}

  @doc """
  Encode an encrypted message using a key

  The key must be a map with the keys `:a` and `:b` and the values must be integers, and
  key `:a` and `m` must be coprime where `m` is the length of the alphabet (26) - that is the only
  common factor shared between the two numbers is one.

  ## Examples
      iex> AffineCipher.Encoder.encode(%{a: 5, b: 8}, "Hello, World!")
      {:ok, "rclla oaplx"}

      iex> AffineCipher.Encoder.encode(%{a: 17, b: 33}, "The quick brown fox jumps over the lazy dog.")
      {:ok, "swxtj npvyk lruol iejdc blaxk swxmh qzglf"}

      iex> AffineCipher.Encoder.encode(%{a: 6, b: 17}, "This is a test.")
      {:error, "a and m must be coprime."}
  """
  @spec encode(key :: AffineCipher.key(), message :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def encode(%{a: a, b: b}, message) do
    with {:ok, key} <- EncodeKey.new(a, b) do
      {:ok, encode_message(key, message)}
    end
  end

  @spec encode_message(key :: Key.t(), message :: String.t()) :: String.t()
  defp encode_message(key, message) do
    message
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "")
    |> String.to_charlist()
    |> Enum.map(&encode_char(key, &1))
    |> Enum.chunk_every(5)
    |> Enum.map_join(" ", &to_string/1)
  end

  @spec encode_char(key :: Key.t(), char :: Chars.valid_chars()) :: Chars.valid_chars()
  defp encode_char(_, char) when char in ?0..?9, do: char

  defp encode_char(key, char) do
    char
    |> Chars.char_to_index()
    |> encode_calculation(key)
    |> Integer.mod(key.m)
    |> Chars.index_to_char()
  end

  defp encode_calculation(char_index, %{a: a, b: b}), do: a * char_index + b
end

defmodule AffineCipher.Decoder do
  @moduledoc """
  A module for decoding a message using an affine cipher.
  """

  alias AffineCipher.{Chars, DecodeKey}

  @doc """
  Decode an encrypted message using a key.

  The key must be a map with the keys `:a` and `:b` and the values must be integers, and
  key `:a` and `m` must be coprime where `m` is the length of the alphabet (26) - that is the only
  common factor shared between the two numbers is one.

  ## Examples
      iex> AffineCipher.Decoder.decode(%{a: 5, b: 8}, "rclla oaplx")
      {:ok, "helloworld"}

      iex> AffineCipher.Decoder.decode(%{a: 17, b: 33}, "swxtj npvyk lruol iejdc blaxk swxmh qzglf")
      {:ok, "thequickbrownfoxjumpsoverthelazydog"}

      iex> AffineCipher.Decoder.decode(%{a: 6, b: 17}, "This is a test.")
      {:error, "a and m must be coprime."}
  """
  @spec decode(key :: AffineCipher.key(), cipher :: String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def decode(%{a: a, b: b}, cipher) do
    with {:ok, decode_key} <- DecodeKey.new(a, b) do
      {:ok, decode_cipher(decode_key, cipher)}
    end
  end

  @spec decode_cipher(key :: DecodeKey.t(), cipher :: String.t()) :: String.t()
  defp decode_cipher(key, cipher) do
    cipher
    |> String.replace(~r/[^a-z0-9]/, "")
    |> String.to_charlist()
    |> Enum.map(&decode_char(key, &1))
    |> Kernel.to_string()
  end

  @spec decode_char(key :: DecodeKey.t(), char :: Chars.valid_chars()) :: Chars.valid_chars()
  defp decode_char(_, char) when char in ?0..?9, do: char

  defp decode_char(key, char) do
    char
    |> Chars.char_to_index()
    |> then(&(key.a * (&1 - key.b)))
    |> Integer.mod(key.m)
    |> Chars.index_to_char()
  end
end
