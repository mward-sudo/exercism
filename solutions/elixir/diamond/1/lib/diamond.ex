defmodule Diamond do
  @doc """
  Given a letter, it prints a diamond starting with 'A',
  with the supplied letter at the widest point.
  """
  @spec build_shape(char) :: String.t()
  def build_shape(?A), do: "A\n"

  def build_shape(target) do
    size = (target - ?A) * 2 + 1

    ?A..target
    |> Enum.map(&build_row(&1, size))
    |> Kernel.++(Enum.map((target - 1)..?A, &build_row(&1, size)))
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp build_row(char, width) do
    outer_spaces = div(width - (char - ?A) * 2 - 1, 2)
    inner_spaces = max((char - ?A) * 2 - 1, 0)

    [
      String.duplicate(" ", outer_spaces),
      <<char>>,
      if(inner_spaces > 0, do: String.duplicate(" ", inner_spaces) <> <<char>>, else: ""),
      String.duplicate(" ", outer_spaces)
    ]
    |> Enum.join()
  end
end
