defmodule BasketballWebsite do
  def extract_from_path(data, path) do
    String.split(path, ".")
    |> case do
      [head] -> data[head]
      [head | tail] -> extract_from_path(data[head], Enum.join(tail, "."))
      _ -> nil
    end
  end

  def get_in_path(data, path) do
    path_list = String.split(path, ".")
    Kernel.get_in(data, path_list)
  end
end
