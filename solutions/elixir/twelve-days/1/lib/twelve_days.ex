defmodule TwelveDays do
  @day_gift %{
    1 => %{day: "first", text: "and a Partridge in a Pear Tree"},
    2 => %{day: "second", text: "two Turtle Doves"},
    3 => %{day: "third", text: "three French Hens"},
    4 => %{day: "fourth", text: "four Calling Birds"},
    5 => %{day: "fifth", text: "five Gold Rings"},
    6 => %{day: "sixth", text: "six Geese-a-Laying"},
    7 => %{day: "seventh", text: "seven Swans-a-Swimming"},
    8 => %{day: "eighth", text: "eight Maids-a-Milking"},
    9 => %{day: "ninth", text: "nine Ladies Dancing"},
    10 => %{day: "tenth", text: "ten Lords-a-Leaping"},
    11 => %{day: "eleventh", text: "eleven Pipers Piping"},
    12 => %{day: "twelfth", text: "twelve Drummers Drumming"}
  }

  @doc """
  Given a `number`, return the song's verse for that specific day, including
  all gifts for previous days in the same line.
  """
  @spec verse(number :: integer) :: String.t()
  def verse(number) do
    day = @day_gift[number].day

    gifts =
      number..1
      |> Enum.map_join(", ", fn n -> @day_gift[n].text end)
      |> String.replace_prefix("and ", "")

    "On the #{day} day of Christmas my true love gave to me: #{gifts}."
  end

  @doc """
  Given a `starting_verse` and an `ending_verse`, return the verses for each
  included day, one per line.
  """
  @spec verses(starting_verse :: integer, ending_verse :: integer) :: String.t()
  def verses(starting_verse, ending_verse) do
    starting_verse..ending_verse
    |> Enum.map_join("\n", &verse/1)
  end

  @doc """
  Sing all 12 verses, in order, one verse per line.
  """
  @spec sing() :: String.t()
  def sing do
    verses(1, 12)
  end
end
