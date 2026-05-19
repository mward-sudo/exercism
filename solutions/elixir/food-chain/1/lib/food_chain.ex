defmodule FoodChain do
  @animals ~w(fly spider bird cat dog goat cow horse)
  @comments %{
    "fly" => "I don't know why she swallowed the fly. Perhaps she'll die.",
    "spider" => "It wriggled and jiggled and tickled inside her.",
    "bird" => "How absurd to swallow a bird!",
    "cat" => "Imagine that, to swallow a cat!",
    "dog" => "What a hog, to swallow a dog!",
    "goat" => "Just opened her throat and swallowed a goat!",
    "cow" => "I don't know how she swallowed a cow!",
    "horse" => "She's dead, of course!"
  }

  @spec recite(start :: integer, stop :: integer) :: String.t()
  def recite(start, stop) do
    start..stop
    |> Enum.map(&verse/1)
    |> Enum.join("\n\n")
    |> Kernel.<>("\n")
  end

  defp verse(8) do
    """
    I know an old lady who swallowed a horse.
    She's dead, of course!
    """
    |> String.trim()
  end

  defp verse(n) do
    animal = Enum.at(@animals, n - 1)

    """
    I know an old lady who swallowed a #{animal}.
    #{@comments[animal]}
    #{build_chain(n)}
    """
    |> String.trim()
  end

  defp build_chain(1), do: ""

  defp build_chain(2),
    do:
      "She swallowed the spider to catch the fly.\nI don't know why she swallowed the fly. Perhaps she'll die."

  defp build_chain(n) do
    n..2
    |> Enum.map_join("\n", fn i ->
      current = Enum.at(@animals, i - 1)
      previous = Enum.at(@animals, i - 2)

      "She swallowed the #{current} to catch the #{previous}#{if i == 3, do: " that wriggled and jiggled and tickled inside her", else: ""}."
    end)
    |> Kernel.<>("\nI don't know why she swallowed the fly. Perhaps she'll die.")
  end
end
