defmodule Clock do
  defstruct hour: 0, minute: 0

  @minutes_per_day 24 * 60

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: Clock
  def new(hour, minute) do
    total_minutes = rem(hour * 60 + minute, @minutes_per_day)

    total_minutes =
      if total_minutes < 0, do: total_minutes + @minutes_per_day, else: total_minutes

    %Clock{
      hour: rem(div(total_minutes, 60), 24),
      minute: rem(total_minutes, 60)
    }
  end

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(Clock, integer) :: Clock
  def add(%Clock{hour: hour, minute: minute}, add_minutes) do
    new(hour, minute + add_minutes)
  end
end

defimpl String.Chars, for: Clock do
  def to_string(%Clock{hour: hour, minute: minute}) do
    :io_lib.format("~2..0B:~2..0B", [hour, minute])
    |> Kernel.to_string()
  end
end

defimpl Inspect, for: Clock do
  def inspect(%Clock{hour: hour, minute: minute}, _opts) do
    "#Clock<#{hour |> Integer.to_string() |> String.pad_leading(2, "0")}:#{minute |> Integer.to_string() |> String.pad_leading(2, "0")}>"
  end
end
