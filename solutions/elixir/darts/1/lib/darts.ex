defmodule Darts do
  @type position :: {number, number}

  @doc """
  Calculate the score of a single dart hitting a target
  """
  @spec score(position) :: integer
  def score({x, y}) do
    outer_radius = 10
    middle_radius = 5
    inner_radius = 1

    [biggest_coordinate | _tail] = Enum.sort([x, y], :desc)

    cond do
      x < 0 or y < 0 -> 0
      biggest_coordinate <= inner_radius -> 10
      biggest_coordinate <= middle_radius -> 5
      biggest_coordinate <= outer_radius -> 1
      true -> 0
    end
  end
end
