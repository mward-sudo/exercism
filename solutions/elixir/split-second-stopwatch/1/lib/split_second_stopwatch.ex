defmodule SplitSecondStopwatch do
  @moduledoc """
  A stopwatch that can be used to track lap times.

  The stopwatch operates as a state machine with three states:
  - `:ready` - Initial state, ready to start
  - `:running` - Currently tracking time
  - `:stopped` - Paused, time tracking suspended
  """

  @type state :: :ready | :running | :stopped

  defmodule Stopwatch do
    @moduledoc """
    Represents the stopwatch state with current lap time, previous laps, and state.
    """

    @type t :: %__MODULE__{
            state: SplitSecondStopwatch.state(),
            current_lap: Time.t(),
            previous_laps: [Time.t()]
          }

    defstruct state: :ready,
              current_lap: ~T[00:00:00],
              previous_laps: []
  end

  @doc """
  Creates a new stopwatch in the ready state.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> SplitSecondStopwatch.state(stopwatch)
      :ready
  """
  @spec new() :: Stopwatch.t()
  def new, do: %Stopwatch{}

  @doc """
  Returns the current state of the stopwatch.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> SplitSecondStopwatch.state(stopwatch)
      :ready
  """
  @spec state(Stopwatch.t()) :: state()
  def state(%Stopwatch{state: state}), do: state

  @doc """
  Returns the current lap time.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> SplitSecondStopwatch.current_lap(stopwatch)
      ~T[00:00:00]
  """
  @spec current_lap(Stopwatch.t()) :: Time.t()
  def current_lap(%Stopwatch{current_lap: current_lap}), do: current_lap

  @doc """
  Returns the list of previously completed lap times.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> SplitSecondStopwatch.previous_laps(stopwatch)
      []
  """
  @spec previous_laps(Stopwatch.t()) :: [Time.t()]
  def previous_laps(%Stopwatch{previous_laps: previous_laps}), do: previous_laps

  @doc """
  Advances the current lap time by the given duration.

  Only advances time when the stopwatch is in the running state.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> |> SplitSecondStopwatch.advance_time(~T[00:00:05])
      iex> SplitSecondStopwatch.current_lap(stopwatch)
      ~T[00:00:05]
  """
  @spec advance_time(Stopwatch.t(), Time.t()) :: Stopwatch.t()
  def advance_time(%Stopwatch{state: :running, current_lap: current_lap} = stopwatch, time) do
    new_lap = add_times(current_lap, time)
    %Stopwatch{stopwatch | current_lap: new_lap}
  end

  def advance_time(%Stopwatch{} = stopwatch, _time), do: stopwatch

  @doc """
  Calculates the total elapsed time including all previous laps and the current lap.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> |> SplitSecondStopwatch.advance_time(~T[00:00:10])
      iex> SplitSecondStopwatch.total(stopwatch)
      ~T[00:00:10]
  """
  @spec total(Stopwatch.t()) :: Time.t()
  def total(%Stopwatch{current_lap: current_lap, previous_laps: previous_laps}) do
    Enum.reduce(previous_laps, current_lap, &add_times/2)
  end

  @doc """
  Starts the stopwatch.

  Can be called from:
  - `:ready` state - begins tracking time
  - `:stopped` state - resumes tracking time

  Returns an error if called from the `:running` state.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> SplitSecondStopwatch.state(stopwatch)
      :running
  """
  @spec start(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def start(%Stopwatch{state: :ready} = stopwatch),
    do: %Stopwatch{stopwatch | state: :running}

  def start(%Stopwatch{state: :stopped} = stopwatch),
    do: %Stopwatch{stopwatch | state: :running}

  def start(%Stopwatch{state: :running}),
    do: {:error, "cannot start an already running stopwatch"}

  @doc """
  Stops the stopwatch, pausing time tracking.

  Can only be called from the `:running` state.

  Returns an error if called from `:ready` or `:stopped` states.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> |> SplitSecondStopwatch.stop()
      iex> SplitSecondStopwatch.state(stopwatch)
      :stopped
  """
  @spec stop(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def stop(%Stopwatch{state: :running} = stopwatch),
    do: %Stopwatch{stopwatch | state: :stopped}

  def stop(%Stopwatch{}),
    do: {:error, "cannot stop a stopwatch that is not running"}

  @doc """
  Records the current lap time and resets the current lap.

  Can only be called from the `:running` state.
  Adds the current lap time to the list of previous laps and resets
  the current lap to zero.

  Returns an error if called from `:ready` or `:stopped` states.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> |> SplitSecondStopwatch.advance_time(~T[00:00:10])
      iex> |> SplitSecondStopwatch.lap()
      iex> SplitSecondStopwatch.previous_laps(stopwatch)
      [~T[00:00:10]]
  """
  @spec lap(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def lap(
        %Stopwatch{state: :running, current_lap: current_lap, previous_laps: previous_laps} =
          stopwatch
      ) do
    %Stopwatch{
      stopwatch
      | current_lap: ~T[00:00:00],
        previous_laps: previous_laps ++ [current_lap]
    }
  end

  def lap(%Stopwatch{}),
    do: {:error, "cannot lap a stopwatch that is not running"}

  @doc """
  Resets the stopwatch to the ready state.

  Can only be called from the `:stopped` state.
  Clears all lap times and resets the current lap to zero.

  Returns an error if called from `:ready` or `:running` states.

  ## Examples

      iex> stopwatch = SplitSecondStopwatch.new()
      iex> |> SplitSecondStopwatch.start()
      iex> |> SplitSecondStopwatch.stop()
      iex> |> SplitSecondStopwatch.reset()
      iex> SplitSecondStopwatch.state(stopwatch)
      :ready
  """
  @spec reset(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def reset(%Stopwatch{state: :stopped}), do: %Stopwatch{}

  def reset(%Stopwatch{}),
    do: {:error, "cannot reset a stopwatch that is not stopped"}

  # Private helper function to add two Time structs
  @spec add_times(Time.t(), Time.t()) :: Time.t()
  defp add_times(time1, time2) do
    {seconds1, _microseconds1} = Time.to_seconds_after_midnight(time1)
    {seconds2, _microseconds2} = Time.to_seconds_after_midnight(time2)

    total_seconds = seconds1 + seconds2

    hours = div(total_seconds, 3600)
    remaining_seconds = rem(total_seconds, 3600)
    minutes = div(remaining_seconds, 60)
    final_seconds = rem(remaining_seconds, 60)

    Time.new!(hours, minutes, final_seconds)
  end
end
