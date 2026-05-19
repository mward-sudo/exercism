defmodule Meetup do
  @moduledoc """
  Calculate meetup dates.
  """

  @type weekday :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday

  @type schedule :: :first | :second | :third | :fourth | :last | :teenth

  @schedule_index %{
    :first => 0,
    :second => 1,
    :third => 2,
    :fourth => 3,
    :last => -1,
    :teenth => 0
  }

  @days_of_week %{
    :monday => 1,
    :tuesday => 2,
    :wednesday => 3,
    :thursday => 4,
    :friday => 5,
    :saturday => 6,
    :sunday => 7
  }

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(integer, integer, weekday, schedule) :: Date.t()
  def meetup(year, month, weekday, schedule) do
    {year, month, schedule}
    |> date_range()
    |> Enum.filter(&matches_day_of_week?(&1, weekday))
    |> Enum.at(@schedule_index[schedule])
  end

  defp date_range({year, month, :teenth = _schedule}),
    do: Date.range(Date.new!(year, month, 13), Date.new!(year, month, 19))

  defp date_range({year, month, _schedule}) do
    Date.range(
      Date.new!(year, month, 1),
      Date.new!(year, month, 1) |> Date.end_of_month()
    )
  end

  defp matches_day_of_week?(date, weekday),
    do: Date.day_of_week(date) == @days_of_week[weekday]
end
