defmodule Gigasecond do
  @gigasecond 10 ** 9

  @doc """
  Calculate a date one billion seconds after an input date.
  """
  @spec from({{pos_integer, pos_integer, pos_integer}, {pos_integer, pos_integer, pos_integer}}) ::
          {{pos_integer, pos_integer, pos_integer}, {pos_integer, pos_integer, pos_integer}}
  def from({{year, month, day}, {hours, minutes, seconds}}) do
    {:ok, date_time} = NaiveDateTime.new(year, month, day, hours, minutes, seconds)

    %{year: year, month: month, day: day, hour: hours, minute: minutes, second: seconds} =
      NaiveDateTime.add(date_time, @gigasecond)

    {{year, month, day}, {hours, minutes, seconds}}
  end
end
