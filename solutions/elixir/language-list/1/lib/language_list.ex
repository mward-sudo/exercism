defmodule LanguageList do
  def new(), do: []

  def add(list, language), do: [language | list]

  def remove([_head | tail]), do: tail

  def first([head | _tail]), do: head

  def count(list), do: Enum.count(list)

  def functional_list?(list), do: Enum.any?(list, &(&1 == "Elixir"))
end
