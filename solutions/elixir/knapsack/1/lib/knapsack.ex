defmodule Knapsack do
  @moduledoc """
  Module for solving the 0/1 Knapsack problem.

  This module provides functions to calculate the maximum value that can be carried
  in a knapsack given a list of items with weights and values, and a maximum weight capacity.
  """

  @doc """
  Return the maximum value that a knapsack can carry.
  """
  @spec maximum_value(items :: [%{value: integer, weight: integer}], maximum_weight :: integer) ::
          integer
  def maximum_value(items, maximum_weight) do
    dp = List.duplicate(0, maximum_weight + 1)

    Enum.reduce(items, dp, fn item, acc ->
      update_dp_for_item(acc, item, maximum_weight)
    end)
    |> Enum.at(maximum_weight)
  end

  @spec update_dp_for_item([integer], %{value: integer, weight: integer}, integer) :: [integer]
  defp update_dp_for_item(dp, item, maximum_weight) do
    Enum.reduce(maximum_weight..item.weight//-1, dp, fn w, acc ->
      take = Enum.at(acc, w - item.weight) + item.value
      not_take = Enum.at(acc, w)
      List.replace_at(acc, w, max(take, not_take))
    end)
  end
end
