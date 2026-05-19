defmodule Grep do
  @moduledoc """
  A simple grep implementation in Elixir.
  """

  @typep grep_map :: %{
           regex: Regex.t(),
           output_flags: [Keyword.t()],
           search_flags: [Keyword.t()],
           files: [file]
         }
  @typep file :: %{
           filename: String.t(),
           content: [String.t()],
           matches: [match]
         }
  @typep match :: %{
           line: integer(),
           content: String.t()
         }

  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    [search_flags, output_flags] = parse_flags_to_keyword_lists(flags)

    files
    |> build_grep_map(pattern, search_flags, output_flags)
    |> run_grep()
    |> generate_output()
  end

  @spec parse_flags_to_keyword_lists([String.t()]) :: [Keyword.t()]
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

  @spec build_grep_map([String.t()], String.t(), [String.t()], [String.t()]) :: grep_map
  defp build_grep_map(files, pattern, search_flags, output_flags) do
    %{
      regex: build_regex(pattern, search_flags),
      output_flags: output_flags,
      search_flags: search_flags,
      files: build_files(files)
    }
  end

  @spec build_regex(String.t(), [String.t()]) :: Regex.t()
  defp build_regex(pattern, search_flags) do
    Regex.compile!(
      build_regex_pattern(pattern, search_flags),
      build_regex_flags(search_flags)
    )
  end

  @spec build_regex_pattern(String.t(), [String.t()]) :: String.t()
  defp build_regex_pattern(pattern, search_flags) do
    if Keyword.get(search_flags, :whole_line_match, false),
      do: "^#{pattern}$",
      else: pattern
  end

  @spec build_regex_flags([String.t()]) :: [Atom.t()]
  defp build_regex_flags(search_flags) do
    if Keyword.get(search_flags, :case_insensitive, false),
      do: [:caseless],
      else: []
  end

  @spec build_files([String.t()]) :: [file]
  defp build_files(files), do: Enum.map(files, &read_file/1)

  @spec read_file(String.t()) :: file
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

  @spec run_grep(grep_map) :: grep_map
  defp run_grep(grep_map) do
    files =
      grep_map.files
      |> Enum.map(fn file -> run_grep_on_file(file, grep_map) end)

    Map.put(grep_map, :files, files)
  end

  @spec run_grep_on_file(file, grep_map) :: file
  defp run_grep_on_file(file, grep_map) do
    Map.put(file, :matches, get_file_matches(file, grep_map.regex, grep_map.search_flags))
  end

  @spec get_file_matches(file, Regex.t(), [Keyword.t()]) :: [match]
  defp get_file_matches(file, regex, search_flags) do
    invert = Keyword.get(search_flags, :invert, false)

    file.content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} -> regex_match?(regex, line, invert) end)
    |> Enum.map(fn {line, index} -> build_match(line, index) end)
  end

  @spec regex_match?(Regex.t(), binary, boolean) :: boolean
  defp regex_match?(regex, line, invert) do
    if invert,
      do: !Regex.match?(regex, line),
      else: Regex.match?(regex, line)
  end

  @spec build_match(String.t(), integer()) :: match
  defp build_match(line, index) do
    %{
      line: index + 1,
      content: line
    }
  end

  @spec generate_output(grep_map) :: String.t()
  defp generate_output(%{output_flags: output_flags} = grep_map) do
    output =
      case Keyword.get(output_flags, :file_names_only, false) do
        true -> generate_file_names_output(grep_map)
        false -> generate_names_output(grep_map)
      end

    if output == "", do: "", else: "#{output}\n"
  end

  @spec generate_file_names_output(grep_map) :: String.t()
  defp generate_file_names_output(%{files: files}) do
    files
    |> Enum.filter(fn file -> length(file.matches) > 0 end)
    |> Enum.map_join("\n", fn file -> file.filename end)
  end

  @spec generate_names_output(grep_map) :: String.t()
  defp generate_names_output(%{files: files}) when files == [] do
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

  @spec maybe_add_line_numbers(grep_map) :: grep_map
  defp maybe_add_line_numbers(%{output_flags: output_flags, files: files} = grep_map) do
    if Keyword.get(output_flags, :line_numbers, false) do
      files = Enum.map(files, &add_line_numbers_to_matches/1)
      Map.put(grep_map, :files, files)
    else
      grep_map
    end
  end

  @spec add_line_numbers_to_matches(file) :: file
  defp add_line_numbers_to_matches(%{matches: matches} = file) do
    matches = Enum.map(matches, &add_line_number_to_match/1)
    Map.put(file, :matches, matches)
  end

  @spec add_line_number_to_match(match) :: match
  defp add_line_number_to_match(%{line: line, content: content} = match) do
    Map.put(match, :content, "#{line}:#{content}")
  end

  @spec output_matches(grep_map) :: String.t()
  defp output_matches(%{files: files}) do
    files
    |> Enum.flat_map(fn file -> Enum.map(file.matches, & &1.content) end)
    |> Enum.join("\n")
  end

  @spec add_filenames(grep_map) :: grep_map
  defp add_filenames(%{files: files} = grep_map) do
    files = Enum.map(files, &add_filename_to_matches/1)
    Map.put(grep_map, :files, files)
  end

  @spec add_filename_to_matches(file) :: file
  defp add_filename_to_matches(%{filename: filename, matches: matches} = file) do
    matches = Enum.map(matches, &add_filename_to_match(filename, &1))
    Map.put(file, :matches, matches)
  end

  @spec add_filename_to_match(String.t(), match) :: match
  defp add_filename_to_match(filename, %{content: content} = match) do
    Map.put(match, :content, "#{filename}:#{content}")
  end
end
