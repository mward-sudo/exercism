defmodule BinarySearch do
  @spec search(tuple, integer) :: {:ok, integer} | :not_found
  def search(numbers, key) do
    list = Tuple.to_list(numbers)
    max = Enum.count(list) - 1

    search(list, key, 0, max)
  end

  @spec search(numbers :: [integer()], key :: integer()) :: {:pk, integer} | :not_found
  defp search(numbers, key, a, a) do
    elem = Enum.at(numbers, a)

    if elem == key do
      {:ok, a}
    else
      :not_found
    end
  end

  defp search(_numbers, _key, min, max) when max < min, do: :not_found

  defp search(numbers, key, min, max) do
    middle_index = Integer.floor_div(max - min, 2) + min
    middle_elem = Enum.at(numbers, middle_index)

    cond do
      key == middle_elem -> {:ok, middle_index}
      key < middle_elem -> search(numbers, key, min, middle_index - 1)
      key > middle_elem -> search(numbers, key, middle_index + 1, max)
    end
  end
end
