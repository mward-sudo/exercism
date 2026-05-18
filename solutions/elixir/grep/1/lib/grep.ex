defmodule Grep do
  @typep file :: %{filename: String.t(), content: [binary()], matches: [match]}
  @typep match :: %{line: integer(), content: String.t()}

  @output_flags ["-n", "-l"]
  @search_flags ["-i", "-v", "-x"]

  # Instructions
  # Search files for lines matching a search string and return all matching lines.

  # The Unix grep command searches files for lines that match a regular expression. Your task is to implement a simplified grep command, which supports searching for fixed strings.

  # The grep command takes three arguments:

  # The string to search for.
  # Zero or more flags for customizing the command's behavior.
  # One or more files to search in.
  # It then reads the contents of the specified files (in the order specified), finds the lines that contain the search string, and finally returns those lines in the order in which they were found. When searching in multiple files, each matching line is prepended by the file name and a colon (':').

  # Flags
  # The grep command supports the following flags:

  # -n Prepend the line number and a colon (':') to each line in the output, placing the number after the filename (if present).
  # -l Output only the names of the files that contain at least one matching line.
  # -i Match using a case-insensitive comparison.
  # -v Invert the program -- collect all lines that fail to match.
  # -x Search only for lines where the search string matches the entire line.

  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) when length(files) > 1 do
    output_flags = Enum.filter(flags, &(&1 in @output_flags))

    output =
      files
      |> Enum.map(&grep_file(pattern, flags, &1))
      |> Enum.filter(fn file -> file.matches != [] end)
      |> Enum.map_join("\n", &format_with_filename(&1, output_flags))

    case output do
      "" ->
        ""

      _ ->
        """
        #{output}
        """
    end
  end

  def grep(pattern, flags, [file | _]) do
    output_flags = Enum.filter(flags, &(&1 in @output_flags))

    output =
      [grep_file(pattern, flags, file)]
      |> Enum.map_join("\n", &format(&1, output_flags))

    case output do
      "" ->
        ""

      _ ->
        """
        #{output}
        """
    end
  end

  def grep_file(pattern, flags, file) do
    search_flags = Enum.filter(flags, &(&1 in @search_flags))

    file
    |> read_file()
    |> file_search(pattern, search_flags)
  end

  @spec read_file(String.t()) :: file
  defp read_file(file) do
    %{
      filename: file,
      content: File.read!(file) |> String.split("\n"),
      matches: []
    }
  end

  # Returns a list matched lines, with line numbers for the given
  # string and pattern
  @spec file_search(file, String.t(), [String.t()]) :: file
  defp file_search(file, pattern, search_flags) do
    file
    |> Map.get(:content)
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} -> regex_filter(line, pattern, search_flags) end)
    |> Enum.filter(fn {line, _} -> line != "" end)
    |> Enum.map(fn {line, index} -> %{line: index + 1, content: line} end)
    |> case do
      [] -> file
      matches -> Map.put(file, :matches, matches)
    end
  end

  defp regex_filter(line, pattern, search_flags) do
    pattern = if "-x" in search_flags, do: "^#{pattern}$", else: pattern
    pattern = if "-i" in search_flags, do: ~r/#{pattern}/i, else: ~r/#{pattern}/

    cond do
      "-v" in search_flags -> !Regex.match?(pattern, line)
      true -> Regex.match?(pattern, line)
    end
  end

  @spec format(file, [String.t()]) :: String.t()
  defp format(file, flags, opts \\ []) do
    filename = Map.get(file, :filename)
    matches = Map.get(file, :matches)
    add_filename = Keyword.get(opts, :add_filename, false)

    cond do
      "-l" in flags ->
        matches
        |> Enum.map(fn _ -> filename end)
        |> Enum.dedup()
        |> Enum.join("\n")

      "-n" in flags and add_filename ->
        matches
        |> Enum.map_join("\n", fn match -> "#{filename}:#{match.line}:#{match.content}" end)

      "-n" in flags ->
        matches |> Enum.map_join("\n", fn match -> "#{match.line}:#{match.content}" end)

      add_filename ->
        matches |> Enum.map_join("\n", fn match -> "#{filename}:#{match.content}" end)

      true ->
        matches |> Enum.map_join("\n", fn match -> match.content end)
    end
  end

  @spec format_with_filename(file, [String.t()]) :: String.t()
  defp format_with_filename(file, flags) do
    format(file, flags, add_filename: true)
  end
end
