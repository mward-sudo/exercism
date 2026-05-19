defmodule FlattenArray do
  @doc """
    Accept a list and return the list flattened without nil values.

    ## Examples

      iex> FlattenArray.flatten([1, [2], 3, nil])
      [1,2,3]

      iex> FlattenArray.flatten([nil, nil])
      []

  """

  @spec flatten(list) :: list
  def flatten(list) do
    list
    |> Enum.flat_map(fn
      elem when is_list(elem) -> flatten(elem)
      elem -> [elem]
    end)
    |> Enum.reject(&(&1 == nil))
  end
end
