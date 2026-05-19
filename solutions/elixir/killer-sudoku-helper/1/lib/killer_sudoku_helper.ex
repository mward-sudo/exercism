defmodule KillerSudokuHelper do
  @type cage :: %{exclude: [integer], size: integer, sum: integer}

  @doc """
  Return the possible combinations of `size` distinct numbers from 1-9 excluding `exclude` that sum up to `sum`.
  """
  @spec combinations(cage :: cage) :: [[integer()]]
  def combinations(%{size: size, sum: sum, exclude: exclude}) do
    combinations(size, sum, exclude)
  end

  @spec combinations(integer(), integer(), [integer()]) :: [[integer()]]
  def combinations(1, sum, exclude) do
    if sum in 1..9 and sum not in exclude, do: [[sum]], else: []
  end

  def combinations(size, sum, exclude) do
    1..9
    |> Enum.filter(fn x -> x not in exclude end)
    |> Enum.flat_map(fn x ->
      combinations(size - 1, sum - x, [x | exclude])
      |> Enum.map(fn xs -> [x | xs] end)
      |> Enum.map(fn xs -> Enum.sort(xs) end)
    end)
    |> Enum.uniq()
  end
end
