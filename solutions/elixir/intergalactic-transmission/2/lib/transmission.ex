defmodule Transmission do
  @moduledoc """
  Implements intergalactic transmission encoding and decoding using parity bits.

  This module handles the transmission of messages over long distances where bit errors
  can occur. It uses a simple parity bit system to detect transmission errors:
  - Messages are split into 7-bit chunks
  - Each chunk gets an 8th bit (parity bit) added as the rightmost bit
  - The parity bit ensures an even number of 1 bits in each transmitted byte
  - On reception, messages with odd parity indicate transmission errors
  """

  import Bitwise

  # Constants
  @data_bits_per_transmission 7
  @transmission_byte_size 8

  @doc """
  Return the transmission sequence for a message.

  Takes a binary message and converts it into a transmission sequence by:
  1. Taking every 7 bits of data from the message
  2. Adding a parity bit (as the rightmost bit) to make an even number of 1 bits
  3. Padding the last byte with 0s if needed

  ## Examples

      iex> Transmission.get_transmit_sequence(<<>>)
      <<>>

      iex> Transmission.get_transmit_sequence(<<0x00>>)
      <<0x00, 0x00>>

      iex> Transmission.get_transmit_sequence(<<0xC0, 0x01, 0xC0, 0xDE>>)
      <<0xC0, 0x00, 0x71, 0x1B, 0xE1>>
  """
  @spec get_transmit_sequence(binary()) :: binary()
  def get_transmit_sequence(message) do
    encode_with_parity(message, <<>>, 0, 0)
  end

  @doc """
  Return the message decoded from the received transmission.

  Takes a transmission sequence and decodes it by:
  1. Checking that each byte has even parity
  2. Extracting the 7 data bits from each byte (excluding the parity bit)
  3. Reconstructing the original message

  Returns `{:ok, message}` if all parity checks pass, or
  `{:error, "wrong parity"}` if any byte has incorrect parity.

  ## Examples

      iex> Transmission.decode_message(<<>>)
      {:ok, <<>>}

      iex> Transmission.decode_message(<<0x00, 0x00>>)
      {:ok, <<0x00>>}

      iex> Transmission.decode_message(<<0xC0, 0x00, 0x71, 0x1B, 0xE1>>)
      {:ok, <<0xC0, 0x01, 0xC0, 0xDE>>}

      iex> Transmission.decode_message(<<0x07, 0x00>>)
      {:error, "wrong parity"}
  """
  @spec decode_message(binary()) :: {:ok, binary()} | {:error, String.t()}
  def decode_message(received_data) do
    case check_parity_and_decode(received_data, <<>>, 0, 0) do
      {:error, reason} -> {:error, reason}
      decoded -> {:ok, decoded}
    end
  end

  # Private helper functions

  # Encodes the message by adding parity bits after every 7 bits of data.
  # Accumulates bits in a buffer until we have enough to emit a transmission byte.
  @spec encode_with_parity(binary(), binary(), non_neg_integer(), non_neg_integer()) :: binary()
  defp encode_with_parity(<<>>, output, _bit_accumulator, 0), do: output

  defp encode_with_parity(message, output, bit_accumulator, accumulated_bit_count)
       when accumulated_bit_count >= @data_bits_per_transmission do
    # We have enough bits to create a transmission byte
    transmission_byte = create_transmission_byte(bit_accumulator, accumulated_bit_count)
    remaining_bits = accumulated_bit_count - @data_bits_per_transmission
    remaining_accumulator = keep_lowest_bits(bit_accumulator, remaining_bits)

    encode_with_parity(message, output <> <<transmission_byte>>, remaining_accumulator, remaining_bits)
  end

  defp encode_with_parity(<<current_byte::8, rest::binary>>, output, bit_accumulator, accumulated_bit_count) do
    # Add the current byte to our bit accumulator
    new_accumulator = (bit_accumulator <<< @transmission_byte_size) ||| current_byte
    new_count = accumulated_bit_count + @transmission_byte_size

    encode_with_parity(rest, output, new_accumulator, new_count)
  end

  defp encode_with_parity(<<>>, output, bit_accumulator, accumulated_bit_count)
       when accumulated_bit_count > 0 do
    # Handle remaining bits by padding with zeros
    padded_data = pad_to_seven_bits(bit_accumulator, accumulated_bit_count)
    transmission_byte = add_parity_bit(padded_data)

    output <> <<transmission_byte>>
  end

  # Creates a transmission byte from the accumulated bits by extracting
  # the top 7 bits and adding a parity bit
  @spec create_transmission_byte(non_neg_integer(), non_neg_integer()) :: byte()
  defp create_transmission_byte(bit_accumulator, accumulated_bit_count) do
    data_bits = extract_top_bits(bit_accumulator, accumulated_bit_count, @data_bits_per_transmission)
    add_parity_bit(data_bits)
  end

  # Extracts the top N bits from the accumulator
  @spec extract_top_bits(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp extract_top_bits(accumulator, total_bits, bits_to_extract) do
    shift_amount = total_bits - bits_to_extract
    accumulator >>> shift_amount
  end

  # Keeps only the lowest N bits of a value
  @spec keep_lowest_bits(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp keep_lowest_bits(value, bit_count) do
    mask = create_bit_mask(bit_count)
    value &&& mask
  end

  # Creates a bitmask with N ones (e.g., 3 bits -> 0b111)
  @spec create_bit_mask(non_neg_integer()) :: non_neg_integer()
  defp create_bit_mask(0), do: 0
  defp create_bit_mask(bit_count), do: (1 <<< bit_count) - 1

  # Pads data to 7 bits by shifting left
  @spec pad_to_seven_bits(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  defp pad_to_seven_bits(data, current_bit_count) do
    padding_needed = @data_bits_per_transmission - current_bit_count
    data <<< padding_needed
  end

  # Adds parity bit to 7 bits of data, creating an 8-bit transmission byte
  @spec add_parity_bit(non_neg_integer()) :: byte()
  defp add_parity_bit(seven_bit_data) do
    parity_bit = calculate_parity(seven_bit_data)
    (seven_bit_data <<< 1) ||| parity_bit
  end

  # Checks parity for each transmitted byte and reconstructs the original message.
  # Accumulates data bits until we have enough to form complete message bytes.
  @spec check_parity_and_decode(binary(), binary(), non_neg_integer(), non_neg_integer()) :: binary() | {:error, String.t()}
  defp check_parity_and_decode(<<>>, decoded_output, _bit_accumulator, _accumulated_bit_count) do
    # Any leftover bits are padding zeros from the encoding process
    decoded_output
  end

  defp check_parity_and_decode(<<transmission_byte::8, rest::binary>>, decoded_output, bit_accumulator, accumulated_bit_count) do
    if has_valid_parity?(transmission_byte) do
      data_bits = extract_data_bits(transmission_byte)
      new_accumulator = (bit_accumulator <<< @data_bits_per_transmission) ||| data_bits
      new_count = accumulated_bit_count + @data_bits_per_transmission

      if new_count >= @transmission_byte_size do
        # We have enough bits to extract a complete message byte
        message_byte = extract_top_bits(new_accumulator, new_count, @transmission_byte_size)
        remaining_bits = new_count - @transmission_byte_size
        remaining_accumulator = keep_lowest_bits(new_accumulator, remaining_bits)

        check_parity_and_decode(rest, decoded_output <> <<message_byte>>, remaining_accumulator, remaining_bits)
      else
        # Not enough bits yet, keep accumulating
        check_parity_and_decode(rest, decoded_output, new_accumulator, new_count)
      end
    else
      {:error, "wrong parity"}
    end
  end

  # Checks if a byte has valid even parity (even number of 1 bits)
  @spec has_valid_parity?(byte()) :: boolean()
  defp has_valid_parity?(byte) do
    ones_count = count_ones(byte)
    rem(ones_count, 2) == 0
  end

  # Extracts the 7 data bits from a transmission byte (removes parity bit)
  @spec extract_data_bits(byte()) :: non_neg_integer()
  defp extract_data_bits(transmission_byte) do
    transmission_byte >>> 1
  end

  # Calculates the parity bit needed to make the total number of 1s even.
  # Returns 0 if data already has even number of 1s, otherwise returns 1.
  @spec calculate_parity(non_neg_integer()) :: 0 | 1
  defp calculate_parity(data_bits) do
    ones_count = count_ones(data_bits)

    case rem(ones_count, 2) do
      0 -> 0  # Already even, parity bit is 0
      1 -> 1  # Odd count, parity bit is 1
    end
  end

  # Counts the number of 1 bits in a value using recursive bit checking
  @spec count_ones(non_neg_integer()) :: non_neg_integer()
  defp count_ones(0), do: 0
  defp count_ones(value) do
    lowest_bit = value &&& 1
    lowest_bit + count_ones(value >>> 1)
  end
end
