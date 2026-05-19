defmodule OcrNumbers do
  @moduledoc """
  OcrNumbers is a module that provides functionality to convert a 3 x 4 grid of pipes, underscores, and spaces
  into the corresponding number representation. Each digit is represented by a specific pattern of characters,
  and the module can identify these patterns to determine which number is being represented. If the input does not
  match any known pattern, it will return a "?" to indicate that the input is garbled.
  """

  @doc """
  Given a 3 x 4 grid of pipes, underscores, and spaces, determine which number is represented, or
  whether it is garbled.
  """
  @spec convert([String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  def convert(input) do
    with :ok <- validate_line_count(input),
         :ok <- validate_column_count(input) do
      input
      |> Enum.chunk_every(4)
      |> Enum.map_join(",", &process_block/1)
      |> then(&{:ok, &1})
    end
  end

  defp validate_line_count(input) do
    case length(input) |> rem(4) do
      0 -> :ok
      _ -> {:error, "invalid line count"}
    end
  end

  defp validate_column_count(input) do
    if Enum.all?(input, &validate_line_column_count/1) do
      :ok
    else
      {:error, "invalid column count"}
    end
  end

  defp validate_line_column_count(line) do
    len = line |> String.length()
    len > 0 and rem(len, 3) == 0
  end

  defp process_block(block) do
    block
    |> Enum.take(3)
    |> Enum.map(&process_line/1)
    |> Enum.zip()
    |> Enum.map_join(&process_char/1)
  end

  defp process_line(line) do
    line
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join/1)
  end

  defp process_char({" _ ", "| |", "|_|"}), do: "0"
  defp process_char({"   ", "  |", "  |"}), do: "1"
  defp process_char({" _ ", " _|", "|_ "}), do: "2"
  defp process_char({" _ ", " _|", " _|"}), do: "3"
  defp process_char({"   ", "|_|", "  |"}), do: "4"
  defp process_char({" _ ", "|_ ", " _|"}), do: "5"
  defp process_char({" _ ", "|_ ", "|_|"}), do: "6"
  defp process_char({" _ ", "  |", "  |"}), do: "7"
  defp process_char({" _ ", "|_|", "|_|"}), do: "8"
  defp process_char({" _ ", "|_|", " _|"}), do: "9"
  defp process_char(_), do: "?"
end
