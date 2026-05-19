defmodule LibraryFees do
  @checkout_days 28
  @monday_return_discount 0.5
  @monday 1

  @spec datetime_from_string(binary) :: NaiveDateTime.t()
  def datetime_from_string(string) do
    {:ok, date, 0} = DateTime.from_iso8601(string)
    DateTime.to_naive(date)
  end

  @spec before_noon?(NaiveDateTime.t()) :: boolean()
  def before_noon?(datetime) do
    :lt ==
      datetime
      |> NaiveDateTime.to_time()
      |> Time.compare(~T[12:00:00])
  end

  @spec return_date(NaiveDateTime.t()) :: Date.t()
  def return_date(checkout_datetime) do
    checkout_days =
      checkout_datetime
      |> before_noon?()
      |> calculate_checkout_days()

    checkout_datetime
    |> NaiveDateTime.to_date()
    |> Date.add(checkout_days)
  end

  @spec days_late(planned_return_date :: Date.t(), actual_return_date_time :: NaiveDateTime.t()) ::
          non_neg_integer()
  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> Date.diff(planned_return_date)
    |> to_non_negative_integer()
  end

  @spec monday?(date_time :: NaiveDateTime.t()) :: boolean
  def monday?(date_time) do
    @monday ==
      date_time
      |> NaiveDateTime.to_date()
      |> Date.day_of_week(:monday)
  end

  @spec calculate_late_fee(checkout :: String.t(), return :: String.t(), rate :: integer()) ::
          integer()
  def calculate_late_fee(checkout, return, rate) do
    returned_date = datetime_from_string(return)
    discounted_fine_rate = monday?(returned_date) |> discounted_fine_rate(rate)

    expected_return_date =
      checkout
      |> datetime_from_string()
      |> return_date()

    days_late = days_late(expected_return_date, returned_date)

    (days_late * discounted_fine_rate)
    |> floor
    |> to_non_negative_integer()
  end

  @spec calculate_checkout_days(before_noon? :: boolean()) :: integer()
  defp calculate_checkout_days(true = _before_noon?), do: @checkout_days
  defp calculate_checkout_days(_before_noon?), do: @checkout_days + 1

  @spec discounted_fine_rate(monday? :: boolean(), rate :: integer()) :: integer()
  defp discounted_fine_rate(true = _monday?, rate), do: rate * @monday_return_discount
  defp discounted_fine_rate(_monday?, rate), do: rate

  @spec to_non_negative_integer(value :: integer()) :: non_neg_integer()
  defp to_non_negative_integer(value) when value >= 0, do: value
  defp to_non_negative_integer(_value), do: 0
end
