defmodule Garden do
  @doc """
    Accepts a string representing the arrangement of cups on a windowsill and a
    list with names of students in the class. The student names list does not
    have to be in alphabetical order.

    It decodes that string into the various gardens for each student and returns
    that information in a map.
  """

  # Solution credit to brookerose1312

  @default_names [
    :alice,
    :bob,
    :charlie,
    :david,
    :eve,
    :fred,
    :ginny,
    :harriet,
    :ileana,
    :joseph,
    :kincaid,
    :larry
  ]

  @all_plants %{"C" => :clover, "G" => :grass, "R" => :radishes, "V" => :violets}

  @spec info(String.t(), list) :: map
  def info(info_string, student_names \\ @default_names) do
    plants =
      info_string
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&Enum.map(&1, fn x -> Map.get(@all_plants, x) end))
      |> Enum.map(&Enum.chunk_every(&1, 2))
      |> Enum.zip()
      |> Enum.map(fn {x, y} -> (x ++ y) |> List.to_tuple() end)

    student_names
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.map(fn {name, index} -> {name, Enum.at(plants, index, {})} end)
    |> Map.new()
  end
end
