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
  def parse(m) do
    # Original code
    # patch(Enum.join(Enum.map(String.split(m, "\n"), fn t -> process(t) end)))

    # Improvements:
    # - Readability: Use pipe operator to chain transforms
    # - Performance: Uses map_join rather than seperately mapping and joining, which is more efficient
    m
    |> String.split("\n")
    |> Enum.map_join(&process/1)
    |> patch()
  end

  defp process(t) do
    # Original code
    # if (String.starts_with?(t, "#") && !String.starts_with?(t, "#######")) ||
    #      String.starts_with?(t, "*") do
    #   if String.starts_with?(t, "#") do
    #     enclose_with_header_tag(parse_header_md_level(t))
    #   else
    #     parse_list_md_level(t)
    #   end
    # else
    #   enclose_with_paragraph_tag(String.split(t))
    # end

    # Improvements:
    # - Readability: Use cond to avoid nested if statements, which can be harder to read
    # - Performance: Avoids multiple calls to String.starts_with? by checking for both conditions in a single call, which can be more efficient
    cond do
      String.starts_with?(t, "#") && !String.starts_with?(t, "#######") ->
        enclose_with_header_tag(parse_header_md_level(t))

      String.starts_with?(t, "*") ->
        parse_list_md_level(t)

      true ->
        enclose_with_paragraph_tag(String.split(t))
    end
  end

  defp parse_header_md_level(hwt) do
    # Original code
    # [h | t] = String.split(hwt)
    # {to_string(String.length(h)), Enum.join(t, " ")}

    # Improvements:
    # - Readability: Use the parts option of String.split to limit the number of splits, which can make it clearer that we are only interested in the first part as the header level and
    #   the rest as the header text
    # - Performance: Avoids the overhead of splitting the entire string into a list of words, which can be more efficient for longer strings
    [h | t] = String.split(hwt, " ", parts: 2)

    {
      h |> String.length() |> to_string(),
      List.first(t)
    }
  end

  defp parse_list_md_level(l) do
    # Original code
    # t = String.split(String.trim_leading(l, "* "))
    # "<li>" <> join_words_with_tags(t) <> "</li>"

    # Improvements over original code:
    # - Readability: Use string interpolation for better readability
    #
    content =
      l
      |> String.trim_leading("* ")
      |> String.split()
      |> join_words_with_tags()

    "<li>#{content}</li>"
  end

  defp enclose_with_header_tag({hl, htl}) do
    # Original code
    # "<h" <> hl <> ">" <> htl <> "</h" <> hl <> ">"

    # Improvements:
    # - Readability: Use string interpolation for better readability
    "<h#{hl}>#{htl}</h#{hl}>"
  end

  defp enclose_with_paragraph_tag(t) do
    # Original code
    "<p>#{join_words_with_tags(t)}</p>"
  end

  defp join_words_with_tags(t) do
    # Original code
    # Enum.join(Enum.map(t, fn w -> replace_md_with_tag(w) end), " ")

    # Improvements:
    # - Readability: Use map_join to avoid seperately mapping and joining, which is more efficient and concise
    Enum.map_join(t, " ", &replace_md_with_tag/1)
  end

  defp replace_md_with_tag(w) do
    # Original code
    # replace_suffix_md(replace_prefix_md(w))

    # Improvements:
    # - Readability: Use pipe operator to chain transforms, which can be easier to read
    w
    |> replace_prefix_md()
    |> replace_suffix_md()
  end

  defp replace_prefix_md(w) do
    # Original code
    # cond do
    #   w =~ ~r/^#{"__"}{1}/ -> String.replace(w, ~r/^#{"__"}{1}/, "<strong>", global: false)
    #   w =~ ~r/^[#{"_"}{1}][^#{"_"}+]/ -> String.replace(w, ~r/_/, "<em>", global: false)
    #   true -> w
    # end

    # Improvements:
    # - Readability: Doesn't use regex
    # - Performance: Avoids regex matching and replacement, which can be more efficient for simple
    cond do
      String.starts_with?(w, "__") -> String.replace(w, "__", "<strong>", global: false)
      String.starts_with?(w, "_") -> String.replace(w, "_", "<em>", global: false)
      true -> w
    end
  end

  defp replace_suffix_md(w) do
    # Original code
    # cond do
    #   w =~ ~r/#{"__"}{1}$/ -> String.replace(w, ~r/#{"__"}{1}$/, "</strong>")
    #   w =~ ~r/[^#{"_"}{1}]/ -> String.replace(w, ~r/_/, "</em>")
    #   true -> w
    # end

    # Improvements:
    # - Readability: Doesn't use regex
    # - Performance: Avoids regex matching and replacement, which can be more efficient for simple string replacements
    cond do
      String.ends_with?(w, "__") -> String.replace(w, "__", "</strong>")
      String.ends_with?(w, "_") -> String.replace(w, "_", "</em>")
      true -> w
    end
  end

  defp patch(l) do
    # Original code
    # String.replace(l, "<li>", "<ul>" <> "<li>", global: false)
    # |> String.reverse()
    # |> String.replace(String.reverse("</li>"), String.reverse("</li></ul>"), global: false)
    # |> String.reverse()

    # Improvements:
    # - Readability: Avoids reversing the string, which can be less intuitive and harder to read
    # - Performance: Avoids the overhead of reversing the string multiple times, which can be more efficient for longer strings
    l
    |> String.replace("<li>", "<ul><li>", global: false)
    |> String.replace(~r{</li>(?!.*</li>)}, "</li></ul>")
  end
end
