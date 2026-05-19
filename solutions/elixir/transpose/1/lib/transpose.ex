defmodule Transpose do
  @moduledoc """
  Transposes text where rows become columns and columns become rows.

  Handles jagged input (rows of different lengths) by padding to the left with spaces
  and not padding to the right.
  """

  @doc """
  Given an input text, output it transposed.

  Rows become columns and columns become rows. See https://en.wikipedia.org/wiki/Transpose.

  If the input has rows of different lengths, this is to be solved as follows:
    * Pad to the left with spaces.
    * Don't pad to the right.

  ## Examples

    iex> Transpose.transpose("ABC\\nDE")
    "AD\\nBE\\nC"

    iex> Transpose.transpose("AB\\nDEF")
    "AD\\nBE\\n F"
  """
  @spec transpose(String.t()) :: String.t()
  def transpose(""), do: ""

  def transpose(input) do
    input
    |> parse_to_matrix()
    |> Matrix.transpose()
    |> trim_trailing_nils()
    |> format_output()
  end

  # Parses input text into a rectangular matrix of graphemes.
  # Short rows are padded with nil to ensure all rows have the same length.
  @spec parse_to_matrix(String.t()) :: [[String.t() | nil]]
  defp parse_to_matrix(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> make_rectangular()
  end

  # Pads a jagged matrix to make it rectangular.
  # Shorter rows are padded on the right with nil values.
  @spec make_rectangular([[String.t()]]) :: [[String.t() | nil]]
  defp make_rectangular(matrix) do
    max_length = max_row_length(matrix)

    Enum.map(matrix, fn row ->
      padding_needed = max_length - length(row)
      row ++ List.duplicate(nil, padding_needed)
    end)
  end

  # Removes trailing nil values from each row in the matrix.
  # Implements the "don't pad to the right" rule.
  @spec trim_trailing_nils([[String.t() | nil]]) :: [[String.t() | nil]]
  defp trim_trailing_nils(matrix) do
    matrix
    |> Enum.map(&drop_trailing_nils/1)
  end

  # Removes trailing nil values from a single row.
  @spec drop_trailing_nils([String.t() | nil]) :: [String.t() | nil]
  defp drop_trailing_nils(row) do
    row
    |> Enum.reverse()
    |> Enum.drop_while(&is_nil/1)
    |> Enum.reverse()
  end

  # Returns the length of the longest row in the matrix.
  @spec max_row_length([[any()]]) :: non_neg_integer()
  defp max_row_length(matrix) do
    matrix
    |> Enum.map(&length/1)
    |> Enum.max(fn -> 0 end)
  end

  # Converts a matrix back to a string with newline-separated rows.
  # nil values are converted to spaces for display.
  @spec format_output([[String.t() | nil]]) :: String.t()
  defp format_output(matrix) do
    Enum.map_join(matrix, "\n", fn row ->
      Enum.map_join(row, fn
        nil -> " "
        char -> char
      end)
    end)
  end
end

defmodule Matrix do
  @moduledoc """
  Generic matrix operations for working with 2D lists (lists of lists).
  All operations assume rectangular matrices (all rows have the same length).
  """

  @type matrix(element) :: [[element]]

  @doc """
  Transposes a rectangular matrix.
  Raises ArgumentError if the matrix is jagged (rows have different lengths).
  """
  @spec transpose(matrix(element)) :: matrix(element) when element: any()
  def transpose([]), do: []

  def transpose(matrix) do
    if rectangular?(matrix) do
      do_transpose(matrix)
    else
      raise ArgumentError, "matrix must be rectangular (all rows must have the same length)"
    end
  end

  @doc """
  Checks if a matrix is rectangular (all rows have the same length).
  """
  @spec rectangular?(matrix(any())) :: boolean()
  def rectangular?([]), do: true

  def rectangular?([first_row | _rest] = matrix) do
    first_length = length(first_row)
    Enum.all?(matrix, fn row -> length(row) == first_length end)
  end

  # Performs the actual matrix transposition by iterating over column indices
  # and extracting each column from all rows.
  defp do_transpose(matrix) do
    width = matrix |> List.first() |> length()

    0..(width - 1)
    |> Enum.map(fn col_index ->
      Enum.map(matrix, fn row -> Enum.at(row, col_index) end)
    end)
  end
end
