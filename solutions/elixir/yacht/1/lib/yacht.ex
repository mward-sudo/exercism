defmodule Yacht do
  @moduledoc """
  A scoring system for the Yacht dice game.

  Yacht is a dice game where players roll five dice and score them according
  to different categories. Each category has specific requirements and scoring rules.
  """

  @type category ::
          :ones
          | :twos
          | :threes
          | :fours
          | :fives
          | :sixes
          | :full_house
          | :four_of_a_kind
          | :little_straight
          | :big_straight
          | :choice
          | :yacht

  @doc """
  Calculate the score of 5 dice using the given category's scoring method.
  """
  @spec score(category :: category(), dice :: [integer]) :: integer
  def score(:ones, dice), do: score_number(1, dice)
  def score(:twos, dice), do: score_number(2, dice)
  def score(:threes, dice), do: score_number(3, dice)
  def score(:fours, dice), do: score_number(4, dice)
  def score(:fives, dice), do: score_number(5, dice)
  def score(:sixes, dice), do: score_number(6, dice)
  def score(:full_house, dice), do: score_full_house(dice)
  def score(:four_of_a_kind, dice), do: score_four_of_a_kind(dice)
  def score(:little_straight, dice), do: score_little_straight(dice)
  def score(:big_straight, dice), do: score_big_straight(dice)
  def score(:choice, dice), do: Enum.sum(dice)
  def score(:yacht, dice), do: score_yacht(dice)

  @spec score_number(integer, [integer]) :: integer
  defp score_number(number, dice) do
    dice
    |> Enum.count(&(&1 == number))
    |> Kernel.*(number)
  end

  @spec score_full_house([integer]) :: integer
  defp score_full_house(dice) do
    frequencies = Enum.frequencies(dice)

    case Map.values(frequencies) |> Enum.sort() do
      [2, 3] -> Enum.sum(dice)
      _ -> 0
    end
  end

  @spec score_four_of_a_kind([integer]) :: integer
  defp score_four_of_a_kind(dice) do
    dice
    |> Enum.frequencies()
    |> Enum.find(fn {_value, count} -> count >= 4 end)
    |> case do
      {value, _count} -> value * 4
      nil -> 0
    end
  end

  @spec score_little_straight([integer]) :: integer
  defp score_little_straight(dice) do
    case Enum.sort(dice) do
      [1, 2, 3, 4, 5] -> 30
      _ -> 0
    end
  end

  @spec score_big_straight([integer]) :: integer
  defp score_big_straight(dice) do
    case Enum.sort(dice) do
      [2, 3, 4, 5, 6] -> 30
      _ -> 0
    end
  end

  @spec score_yacht([integer]) :: integer
  defp score_yacht(dice) do
    case Enum.uniq(dice) do
      [_] -> 50
      _ -> 0
    end
  end
end
