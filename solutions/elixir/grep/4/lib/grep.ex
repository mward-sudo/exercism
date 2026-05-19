defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    [search_flags, output_flags] = parse_flags_to_keyword_lists(flags)

    files
    |> build_grep_map(pattern, search_flags, output_flags)
    |> run_grep()
    |> generate_output()
  end

  defp parse_flags_to_keyword_lists(flags) do
    flags
    |> Enum.reduce([[], []], fn flag, [search_flags, output_flags] ->
      case flag do
        "-i" -> [Keyword.put(search_flags, :case_insensitive, true), output_flags]
        "-v" -> [Keyword.put(search_flags, :invert, true), output_flags]
        "-x" -> [Keyword.put(search_flags, :whole_line_match, true), output_flags]
        "-n" -> [search_flags, Keyword.put(output_flags, :line_numbers, true)]
        "-l" -> [search_flags, Keyword.put(output_flags, :file_names_only, true)]
        _ -> [search_flags, output_flags]
      end
    end)
  end

  defp build_grep_map(files, pattern, search_flags, output_flags) do
    %{
      regex: build_regex(pattern, search_flags),
      output_flags: output_flags,
      search_flags: search_flags,
      files: build_files(files)
    }
  end

  defp build_regex(pattern, search_flags) do
    Regex.compile!(
      build_regex_pattern(pattern, search_flags),
      build_regex_flags(search_flags)
    )
  end

  defp build_regex_pattern(pattern, search_flags) do
    if Keyword.get(search_flags, :whole_line_match, false),
      do: "^#{pattern}$",
      else: pattern
  end

  defp build_regex_flags(search_flags) do
    if Keyword.get(search_flags, :case_insensitive, false),
      do: [:caseless],
      else: []
  end

  defp build_files(files), do: Enum.map(files, &read_file/1)

  defp read_file(filename) do
    content =
      File.stream!(filename)
      |> Enum.map(fn line -> String.replace(line, "\n", "") end)

    %{
      filename: filename,
      content: content,
      matches: []
    }
  end

  defp run_grep(grep_map) do
    files =
      grep_map.files
      |> Enum.map(fn file -> run_grep_on_file(file, grep_map) end)

    Map.put(grep_map, :files, files)
  end

  defp run_grep_on_file(file, grep_map) do
    Map.put(file, :matches, get_file_matches(file, grep_map.regex, grep_map.search_flags))
  end

  defp get_file_matches(file, regex, search_flags) do
    invert = Keyword.get(search_flags, :invert, false)

    file.content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} -> regex_match?(regex, line, invert) end)
    |> Enum.map(fn {line, index} -> build_match(line, index) end)
  end

  defp regex_match?(regex, line, invert) do
    if invert,
      do: !Regex.match?(regex, line),
      else: Regex.match?(regex, line)
  end

  defp build_match(line, index) do
    %{
      line: index + 1,
      content: line
    }
  end

  defp generate_output(%{output_flags: output_flags} = grep_map) do
    output =
      case Keyword.get(output_flags, :file_names_only, false) do
        true -> generate_file_names_output(grep_map)
        false -> generate_names_output(grep_map)
      end

    if output == "", do: "", else: "#{output}\n"
  end

  defp generate_file_names_output(%{files: files}) do
    files
    |> Enum.filter(fn file -> length(file.matches) > 0 end)
    |> Enum.map_join("\n", fn file -> file.filename end)
  end

  defp generate_names_output(%{files: files}) when length(files) == 0 do
    ""
  end

  defp generate_names_output(%{files: files} = grep_map) when length(files) == 1 do
    grep_map
    |> maybe_add_line_numbers()
    |> output_matches()
  end

  defp generate_names_output(grep_map) do
    grep_map
    |> maybe_add_line_numbers()
    |> add_filenames()
    |> output_matches()
  end

  defp maybe_add_line_numbers(%{output_flags: output_flags, files: files} = grep_map) do
    if Keyword.get(output_flags, :line_numbers, false) do
      files = Enum.map(files, &add_line_numbers_to_matches/1)
      Map.put(grep_map, :files, files)
    else
      grep_map
    end
  end

  defp add_line_numbers_to_matches(%{matches: matches} = file) do
    matches = Enum.map(matches, &add_line_number_to_match/1)
    Map.put(file, :matches, matches)
  end

  defp add_line_number_to_match(%{line: line, content: content} = match) do
    Map.put(match, :content, "#{line}:#{content}")
  end

  defp output_matches(%{files: files}) do
    files
    |> Enum.flat_map(fn file -> Enum.map(file.matches, & &1.content) end)
    |> Enum.join("\n")
  end

  defp add_filenames(%{files: files} = grep_map) do
    files = Enum.map(files, &add_filename_to_matches/1)
    Map.put(grep_map, :files, files)
  end

  defp add_filename_to_matches(%{filename: filename, matches: matches} = file) do
    matches = Enum.map(matches, &add_filename_to_match(filename, &1))
    Map.put(file, :matches, matches)
  end

  defp add_filename_to_match(filename, %{content: content} = match) do
    Map.put(match, :content, "#{filename}:#{content}")
  end
end
