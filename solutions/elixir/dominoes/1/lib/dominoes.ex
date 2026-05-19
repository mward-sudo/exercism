defmodule Dominoes do
  @type domino :: {1..6, 1..6}
  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?([]), do: true

  def chain?([h | rest]), do: chain?(rest, h)

  defp chain?([], {a, a}), do: true
  defp chain?([], _), do: false

  defp chain?(dominoes, {f, b}) do
    Enum.map(dominoes, fn
      {a, ^b} = one ->
        chain?(List.delete(dominoes, one), {f, a})

      {^b, a} = one ->
        chain?(List.delete(dominoes, one), {f, a})

      _ ->
        false
    end)
    |> Enum.any?(&Function.identity/1)
  end
end
