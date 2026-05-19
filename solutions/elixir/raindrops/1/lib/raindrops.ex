defmodule Raindrops do
  @doc """
  Returns a string based on raindrop factors.

  - If the number contains 3 as a prime factor, output 'Pling'.
  - If the number contains 5 as a prime factor, output 'Plang'.
  - If the number contains 7 as a prime factor, output 'Plong'.
  - If the number does not contain 3, 5, or 7 as a prime factor,
    just pass the number's digits straight through.
  """
  @spec convert(pos_integer) :: String.t()
  def convert(number) do
    [3, 5, 7]
    |> Enum.map(&{&1, rem(number, &1)})
    |> Enum.map(&raindrop_sound/1)
    |> case do
      ["", "", ""] -> Integer.to_string(number)
      sounds -> Enum.join(sounds)
    end
  end

  @spec raindrop_sound({number :: pos_integer, remainder :: pos_integer}) :: String.t()
  defp raindrop_sound({3, 0}), do: "Pling"
  defp raindrop_sound({5, 0}), do: "Plang"
  defp raindrop_sound({7, 0}), do: "Plong"
  defp raindrop_sound({_, _}), do: ""
end
