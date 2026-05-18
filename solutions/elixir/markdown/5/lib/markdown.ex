defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

      iex> Markdown.parse("This is a paragraph")
      "<p>This is a paragraph</p>"

      iex> Markdown.parse("# Header!\\n* __Bold Item__\\n* _Italic Item_")
      "<h1>Header!</h1><ul><li><strong>Bold Item</strong></li><li><em>Italic Item</em></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(markdown) do
    markdown
    |> String.split("\n")
    |> Enum.map_join(&process_block_elements/1)
    |> process_inner_elements()
  end

  # Uses pattern matching to determine the type of block element and processes it accordingly, using bitstring comparisons to identify headings and list items
  defp process_block_elements("#" <> _ = line) do
    line
    |> String.split(" ", parts: 2)
    |> process_heading_line(line)
  end

  defp process_block_elements("* " <> line), do: line |> wrap_with_element("li")
  defp process_block_elements(line), do: line |> wrap_with_element("p")

  # Determines the heading level based on the number of '#' characters and wraps the text in the appropriate heading tag
  defp process_heading_line([level, text], line) do
    case String.length(level) do
      level_count when level_count in 1..6 -> text |> wrap_with_element("h#{level_count}")
      _ -> line |> wrap_with_element("p")
    end
  end

  # Processes inline elements such as bold and italic text, and also wraps list items in a <ul> tag
  defp process_inner_elements(text) do
    text
    |> String.replace(~r/__(.+)__/U, "<strong>\\1</strong>")
    |> String.replace(~r/_(.+)_/U, "<em>\\1</em>")
    |> String.replace(~r/(<li>.+<\/li>)/, "<ul>\\1</ul>")
  end

  # Helper function to wrap content in the specified HTML element
  defp wrap_with_element(content, element), do: "<#{element}>#{content}</#{element}>"
end
