defmodule LibraryFees do
  @checkout_days 28

  @spec datetime_from_string(binary) :: NaiveDateTime.t()
  def datetime_from_string(string) do
    {:ok, date, 0} = DateTime.from_iso8601(string)
    DateTime.to_naive(date)
  end

  @spec before_noon?(NaiveDateTime.t()) :: boolean()
  def before_noon?(datetime) do
    datetime
    |> NaiveDateTime.to_time()
    |> Time.compare(~T[12:00:00]) == :lt
  end

  @spec return_date(NaiveDateTime.t()) :: Date.t()
  def return_date(checkout_datetime) do
    checkout_days =
      @checkout_days +
        if before_noon?(checkout_datetime), do: 0, else: 1

    checkout_datetime
    |> NaiveDateTime.to_date()
    |> Date.add(checkout_days)
  end

  @spec days_late(planned_return_date :: Date.t(), actual_return_date_time :: NaiveDateTime.t()) ::
          non_neg_integer
  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> Date.diff(planned_return_date)
    |> non_negative_integer()
  end

  @spec monday?(date_time :: NaiveDateTime.t()) :: boolean
  def monday?(date_time) do
    date_time
    |> NaiveDateTime.to_date()
    |> Date.day_of_week(:monday)
    |> then(&(&1 == 1))
  end

  @spec calculate_late_fee(checkout :: String.t(), return :: String.t(), rate :: integer()) ::
          integer()
  def calculate_late_fee(checkout, return, rate) do
    expected_return_date =
      checkout
      |> datetime_from_string()
      |> return_date()

    returned_date = datetime_from_string(return)

    discount = if monday?(returned_date), do: 0.5, else: 1.0

    days_late(expected_return_date, returned_date)
    |> then(&(&1 * rate * discount))
    |> floor
    |> non_negative_integer()
  end

  @spec non_negative_integer(value :: integer()) :: non_neg_integer()
  defp non_negative_integer(value) when value >= 0, do: value
  defp non_negative_integer(_value), do: 0
end
