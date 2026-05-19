defmodule SaddlePoints do
  @doc """
  Parses a string representation of a matrix
  to a list of rows
  """
  @spec rows(String.t()) :: [[integer]]
  def rows(str), do: str |> Matrix.new() |> Matrix.rows()

  @doc """
  Parses a string representation of a matrix
  to a list of columns
  """
  @spec columns(String.t()) :: [[integer]]
  def columns(str), do: str |> Matrix.new() |> Matrix.columns()

  @doc """
  Calculates all the saddle points from a string
  representation of a matrix
  """
  @spec saddle_points(String.t()) :: [{integer, integer}]
  def saddle_points(str), do: str |> Matrix.new() |> Matrix.saddle_points()
end

defmodule Matrix do
  defstruct rows: []

  @type t :: %__MODULE__{rows: [[integer]]}

  @doc """
  Creates a new Matrix from a string representation
  """
  @spec new(String.t()) :: t()
  def new(str) when str == "", do: %__MODULE__{}

  def new(str) do
    rows =
      str
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_row/1)

    %__MODULE__{rows: rows}
  end

  @doc """
  Returns a list of rows in the matrix
  """
  @spec rows(t()) :: [[integer]]
  def rows(%__MODULE__{rows: rows}), do: rows

  @doc """
  Returns a list of columns in the matrix
  """
  @spec columns(t()) :: [[integer]]
  def columns(%__MODULE__{rows: rows}) do
    rows
    |> Enum.zip_with(& &1)
  end

  @doc """
  Finds all saddle points in the matrix
  """
  @spec saddle_points(t()) :: [{integer, integer}]
  def saddle_points(%__MODULE__{rows: rows} = matrix) do
    cols = columns(matrix)

    for {row, row_index} <- Enum.with_index(rows, 1),
        {value, col_index} <- Enum.with_index(row, 1),
        value == Enum.max(row),
        value == Enum.min(Enum.at(cols, col_index - 1)),
        do: {row_index, col_index}
  end

  # Private functions

  defp parse_row(row) do
    row
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
