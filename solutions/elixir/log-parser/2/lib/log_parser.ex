defmodule LogParser do
  @log_key_regex ~r/^\[DEBUG\]|\[INFO\]|\[WARNING\]|\[ERROR\]/

  # Matches "<" followed by any number of "*", "=", "~" or "-" until a closing
  # ">"
  @seperators_regex ~r/<[~*\=\~\-r]*>/

  # Maches the string "end-of-line" followed by one or more numbers.
  # Case insensitive
  @end_of_line_regex ~r/end-of-line[\d]+/i

  # Matches "User" followed by one or more whitespace characters,
  # then captures the following non-whitespace characters as 'user'
  @username_regex ~r/User[\s]+(?<user>\S+)/

  def valid_line?(line), do: line =~ @log_key_regex

  def split_line(line), do: String.split(line, @seperators_regex)

  def remove_artifacts(line), do: String.replace(line, @end_of_line_regex, "")

  def tag_with_user_name(line) do
    Regex.named_captures(@username_regex, line)
    |> case do
      %{"user" => user} -> "[USER] #{user} #{line}"
      _ -> line
    end
  end
end
