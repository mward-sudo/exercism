defmodule Darts do
  @type position :: {number, number}

  @spec score(position :: position) :: integer
  def score({x, y}) do
    distance =
      [x ** 2, y ** 2]
      |> Enum.reduce(fn x, acc -> acc + x end)
      |> :math.sqrt()

    cond do
      distance <= 1 -> 10
      distance <= 5 -> 5
      distance <= 10 -> 1
      true -> 0
    end
  end
end
