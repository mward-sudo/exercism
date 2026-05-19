defmodule BirdCount do
  def today([today | _rest]), do: today
  def today([]), do: nil

  def increment_day_count([today | rest]), do: [today + 1 | rest]

  def increment_day_count([]), do: [1]

  # 3 base cases stop recursion - empty list, 0 head value and
  def has_day_without_birds?([]), do: false
  def has_day_without_birds?([0 | _tail]), do: true
  def has_day_without_birds?([_head | tail]), do: has_day_without_birds?(tail)

  def total([]), do: 0
  def total([head]), do: head

  def total([head | tail]) do
    head + total(tail)
  end

  def busy_days([]), do: 0
  def busy_days([head]) when head >= 5, do: 1
  def busy_days([_head]), do: 0
  def busy_days([head | tail]) when head >= 5, do: 1 + busy_days(tail)
  def busy_days([_head | tail]), do: busy_days(tail)
end
