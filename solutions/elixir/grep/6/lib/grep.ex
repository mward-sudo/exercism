defmodule Grep do
  @moduledoc """
  A simple grep implementation in Elixir.
  """

  @typep t :: %__MODULE__{
           regex: Regex.t(),
           flags: Flags.t(),
           files: file_list
         }
  @enforce_keys [:regex, :flags, :files]
  defstruct regex: nil,
            flags: nil,
            files: []

  @typep file_list :: [GrepFile.t()]

  alias Grep.{DefaultFormatter, Flags, RegexPattern}
  alias Grep.File, as: GrepFile

  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    flags = Flags.new(flags)
    regex = RegexPattern.build(pattern, flags.search)

    build_files_list(files)
    |> new(regex, flags)
    |> match()
    |> output(&DefaultFormatter.format/1)
  end

  @spec new([GrepFile.t()], Regex.t(), Flags.t()) :: Grep.t()
  defp new(files, regex, flags), do: %__MODULE__{regex: regex, flags: flags, files: files}

  @spec match(Grep.t()) :: Grep.t()
  defp match(%{files: files, regex: regex, flags: %{search: search_flags}} = grep_struct) do
    %{
      grep_struct
      | files: Enum.map(files, &GrepFile.match(&1, regex, search_flags))
    }
  end

  @spec build_files_list([String.t()]) :: [GrepFile.t()]
  defp build_files_list(files), do: Enum.map(files, &GrepFile.new/1)

  @spec output(Grep.t(), Function.t()) :: String.t()
  defp output(grep_struct, formatter), do: formatter.(grep_struct)
end

defmodule Grep.File do
  @moduledoc """
  This module contains the file struct used by the Grep module.
  """

  @type t :: %__MODULE__{
          filename: String.t(),
          content: [String.t()],
          matches: [Match.t()]
        }
  @enforce_keys [:filename, :content, :matches]
  defstruct filename: "", content: [], matches: []

  alias Grep.Match

  @spec new(String.t()) :: __MODULE__.t()
  def new(filename) do
    content =
      File.stream!(filename)
      |> Enum.map(fn line -> String.replace(line, "\n", "") end)

    %__MODULE__{
      filename: filename,
      content: content,
      matches: []
    }
  end

  @spec match(__MODULE__.t(), Regex.t(), [Keyword.t()]) :: __MODULE__.t()
  def match(file, regex, search_flags),
    do: %{file | matches: get_file_matches(file, regex, search_flags)}

  @spec get_file_matches(__MODULE__.t(), Regex.t(), [Keyword.t()]) :: [Match.t()]
  defp get_file_matches(file, regex, search_flags) do
    invert = Keyword.get(search_flags, :invert, false)

    file.content
    |> Enum.with_index()
    |> Enum.filter(fn {line, _} -> regex_match?(regex, line, invert) end)
    |> Enum.map(fn {line, index} -> Match.new(index + 1, line) end)
  end

  @spec regex_match?(Regex.t(), binary, boolean) :: boolean
  defp regex_match?(regex, line, invert) do
    if invert,
      do: !Regex.match?(regex, line),
      else: Regex.match?(regex, line)
  end
end

defmodule Grep.Match do
  @moduledoc """
  This module contains the match struct used by the Grep module.
  """

  @type t :: %__MODULE__{
          line: integer(),
          content: String.t()
        }
  @enforce_keys [:line, :content]
  defstruct line: 0, content: ""

  @spec new(integer(), String.t()) :: __MODULE__.t()
  def new(line, content) do
    %__MODULE__{
      line: line,
      content: content
    }
  end
end

defmodule Grep.Flags do
  @moduledoc """
  This module contains the flags struct used by the Grep module.
  """

  @type t :: %__MODULE__{
          search: Keyword.t(),
          output: Keyword.t()
        }
  @enforce_keys [:search, :output]
  defstruct search: [], output: []

  @flag_map %{
    "-i" => {:search_flag, :case_insensitive},
    "-v" => {:search_flag, :invert},
    "-x" => {:search_flag, :whole_line_match},
    "-n" => {:output_flag, :line_numbers},
    "-l" => {:output_flag, :file_names_only}
  }

  @spec new(Keyword.t()) :: __MODULE__.t()
  def new(flags) do
    {search_flags, output_flags} = Enum.reduce(flags, {[], []}, &reduce_flags/2)

    %__MODULE__{search: search_flags, output: output_flags}
  end

  @spec reduce_flags(String.t(), {[Keyword.t()], [Keyword.t()]}) :: {[Keyword.t()], [Keyword.t()]}
  defp reduce_flags(flag, {search_flags, output_flags}) do
    case Map.get(@flag_map, flag) do
      {:search_flag, flag} -> {[{flag, true} | search_flags], output_flags}
      {:output_flag, flag} -> {search_flags, [{flag, true} | output_flags]}
      nil -> {search_flags, output_flags}
    end
  end
end

defmodule Grep.RegexPattern do
  @moduledoc """
  This module contains the regex pattern functions used by the Grep module.
  """

  @spec build(String.t(), [Keyword.t()]) :: Regex.t()
  def build(pattern, search_flags) do
    Regex.compile!(
      build_pattern(pattern, search_flags),
      build_flags(search_flags)
    )
  end

  @spec build_pattern(String.t(), [Keyword.t()]) :: String.t()
  defp build_pattern(pattern, search_flags) do
    if Keyword.get(search_flags, :whole_line_match, false),
      do: "^#{pattern}$",
      else: pattern
  end

  @spec build_flags([String.t()]) :: [Atom.t()]
  defp build_flags(search_flags) do
    if Keyword.get(search_flags, :case_insensitive, false),
      do: [:caseless],
      else: []
  end
end

defmodule Grep.Formatter do
  @moduledoc """
  This module defines the behaviours for formatter functions used by the Grep module.
  """

  @callback format(Grep.t()) :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour Grep.Formatter
    end
  end
end

defmodule Grep.DefaultFormatter do
  @moduledoc """
  This module contains the default formatter used by the Grep module.
  """

  use Grep.Formatter

  alias Grep.File, as: GrepFile
  alias Grep.Match

  @impl Grep.Formatter
  @spec format(Grep.t()) :: String.t()
  def format(%{flags: %{output: output_flags}} = grep_struct) do
    output =
      case Keyword.get(output_flags, :file_names_only, false) do
        true -> file_names_only_output(grep_struct)
        false -> all_matches_output(grep_struct)
      end

    if output == "", do: "", else: "#{output}\n"
  end

  @spec file_names_only_output(Grep.t()) :: String.t()
  defp file_names_only_output(%{files: files}) do
    files
    |> Enum.filter(fn file -> length(file.matches) > 0 end)
    |> Enum.map_join("\n", fn file -> file.filename end)
  end

  @spec all_matches_output(Grep.t()) :: String.t()
  defp all_matches_output(%{files: []}), do: ""

  defp all_matches_output(%{} = grep_struct) do
    line_numbers? = Keyword.get(grep_struct.flags.output, :line_numbers, false)

    grep_struct
    |> maybe_add_line_numbers(line_numbers?)
    |> maybe_add_filenames()
    |> output_matches()
  end

  @spec maybe_add_line_numbers(Grep.t(), boolean()) :: Grep.t()
  defp maybe_add_line_numbers(grep_struct, false), do: grep_struct

  defp maybe_add_line_numbers(%{files: files} = grep_struct, _line_numbers?),
    do: %{grep_struct | files: Enum.map(files, &add_line_numbers_to_matches/1)}

  @spec add_line_numbers_to_matches(GrepFile.t()) :: GrepFile.t()
  defp add_line_numbers_to_matches(%{matches: matches} = file),
    do: %{file | matches: Enum.map(matches, &add_line_number_to_match/1)}

  @spec add_line_number_to_match(Match.t()) :: Match.t()
  defp add_line_number_to_match(%{line: line, content: content} = match),
    do: %{match | content: "#{line}:#{content}"}

  @spec maybe_add_filenames(Grep.t()) :: Grep.t()
  defp maybe_add_filenames(%{files: [_]} = grep_struct), do: grep_struct

  defp maybe_add_filenames(%{files: files} = grep_struct),
    do: %{grep_struct | files: Enum.map(files, &add_filename_to_matches/1)}

  @spec add_filename_to_matches(GrepFile.t()) :: GrepFile.t()
  defp add_filename_to_matches(%{filename: filename, matches: matches} = file),
    do: %{file | matches: Enum.map(matches, &add_filename_to_match(filename, &1))}

  @spec add_filename_to_match(String.t(), Match.t()) :: Match.t()
  defp add_filename_to_match(filename, %{content: content} = match),
    do: %{match | content: "#{filename}:#{content}"}

  @spec output_matches(Grep.t()) :: String.t()
  defp output_matches(%{files: files}) do
    files
    |> Enum.flat_map(fn file -> Enum.map(file.matches, & &1.content) end)
    |> Enum.join("\n")
  end
end
