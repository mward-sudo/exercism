defmodule Bob do
  @spec hey(String.t()) :: String.t()
  def hey(input) do
    case input |> String.trim() |> analyse_input() do
      %{blank?: true} -> "Fine. Be that way!"
      %{question?: true, shouted?: true} -> "Calm down, I know what I'm doing!"
      %{shouted?: true} -> "Whoa, chill out!"
      %{question?: true} -> "Sure."
      _ -> "Whatever."
    end
  end

  defp analyse_input(input) do
    %{
      blank?: blank?(input),
      question?: question?(input),
      shouted?: shouted?(input)
    }
  end

  defp shouted?(str), do: str == String.upcase(str) and str !== String.downcase(str)
  defp question?(str), do: String.ends_with?(str, "?")
  defp blank?(str), do: str == ""
end
