defmodule BafflingBirthdays do
  @moduledoc """
  Estimate the probability of shared birthdays in a group of people.

  This module implements functions to explore the birthday paradox,
  which states that in a group of just 23 people, there's over 50%
  probability that at least two people share the same birthday.
  """

  @doc """
  Checks if at least two birthdates share the same birthday (month and day).

  A birthday is defined as the month and day only, ignoring the year.
  Returns true if any two birthdates have the same month and day,
  even if they are from different years.

  ## Examples

      iex> BafflingBirthdays.shared_birthday?([~D[2000-01-01]])
      false

      iex> BafflingBirthdays.shared_birthday?([~D[1999-10-23], ~D[1988-10-23]])
      true

      iex> BafflingBirthdays.shared_birthday?([~D[2000-01-01], ~D[2000-01-02]])
      false
  """
  @spec shared_birthday?(birthdates :: [Date.t()]) :: boolean()
  def shared_birthday?(birthdates) do
    # Extract month-day tuples from all birthdates
    birthdays = Enum.map(birthdates, fn date -> {date.month, date.day} end)

    # Check if the number of unique birthdays is less than total birthdates
    # This means at least two birthdates share the same birthday
    length(Enum.uniq(birthdays)) < length(birthdays)
  end

  @doc """
  Generates a list of random birthdates.

  Generates `group_size` random birthdates uniformly distributed across
  all 365 possible days in a non-leap year. Each day is equally likely.

  The year is chosen to ensure it is not a leap year, satisfying the
  birthday paradox assumption of exactly 365 possible birthdays.

  ## Parameters

    - group_size: The number of random birthdates to generate

  ## Examples

      iex> dates = BafflingBirthdays.random_birthdates(10)
      iex> length(dates)
      10

      iex> dates = BafflingBirthdays.random_birthdates(100)
      iex> Enum.all?(dates, &(!Date.leap_year?(&1)))
      true
  """
  @spec random_birthdates(group_size :: integer()) :: [Date.t()]
  def random_birthdates(group_size) do
    # Use a non-leap year to ensure exactly 365 days
    year = 2023

    # Generate group_size random dates
    1..group_size
    |> Enum.map(fn _ ->
      # Pick a random day from 1 to 365
      day_of_year = Enum.random(1..365)

      # Convert day of year to a date
      Date.add(Date.new!(year, 1, 1), day_of_year - 1)
    end)
  end

  @doc """
  Estimates the probability that at least two people share a birthday.

  Uses Monte Carlo simulation to estimate the probability that in a group
  of `group_size` people, at least two share the same birthday.

  The simulation runs 600 trials, each generating random birthdates and
  checking for shared birthdays. The probability is returned as a percentage.

  ## Parameters

    - group_size: The number of people in the group

  ## Returns

  A float representing the estimated probability as a percentage (0.0 to 100.0)

  ## Examples

      iex> BafflingBirthdays.estimated_probability_of_shared_birthday(1)
      0.0

      iex> prob = BafflingBirthdays.estimated_probability_of_shared_birthday(23)
      iex> prob > 40.0 and prob < 60.0
      true
  """
  @spec estimated_probability_of_shared_birthday(group_size :: integer()) :: float()
  def estimated_probability_of_shared_birthday(group_size) do
    # For a group of 1, probability is 0
    if group_size <= 1 do
      0.0
    else
      # Run 600 simulations for statistical reliability
      # (as suggested by test comments for billion-to-one confidence)
      sample_size = 600

      # Count how many simulations result in a shared birthday
      shared_count =
        1..sample_size
        |> Enum.count(fn _ ->
          group_size
          |> random_birthdates()
          |> shared_birthday?()
        end)

      # Convert to percentage
      shared_count / sample_size * 100.0
    end
  end
end
