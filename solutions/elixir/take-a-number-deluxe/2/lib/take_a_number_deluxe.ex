defmodule TakeANumberDeluxe do
  # Client API
  use GenServer

  @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
  def start_link(init_arg) do
    timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)

    case TakeANumberDeluxe.State.new(init_arg[:min_number], init_arg[:max_number], timeout) do
      {:ok, state} ->
        GenServer.start_link(__MODULE__, state, timeout: timeout)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec report_state(pid()) :: TakeANumberDeluxe.State.t()
  def report_state(machine) do
    GenServer.call(machine, :report_state)
  end

  @spec queue_new_number(pid()) :: {:ok, integer()} | {:error, atom()}
  def queue_new_number(machine) do
    state = report_state(machine)

    case TakeANumberDeluxe.State.queue_new_number(state) do
      {:ok, new_number, new_state} ->
        GenServer.call(machine, {:update_state, new_state})
        {:ok, new_number}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec serve_next_queued_number(pid(), integer() | nil) :: {:ok, integer()} | {:error, atom()}
  def serve_next_queued_number(machine, priority_number \\ nil) do
    state = report_state(machine)

    case TakeANumberDeluxe.State.serve_next_queued_number(state, priority_number) do
      {:ok, new_number, new_state} ->
        GenServer.call(machine, {:update_state, new_state})
        {:ok, new_number}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec reset_state(pid()) :: :ok
  def reset_state(machine) do
    state = report_state(machine)

    {:ok, new_state} =
      TakeANumberDeluxe.State.new(state.min_number, state.max_number, state.auto_shutdown_timeout)

    GenServer.cast(machine, {:update_state, new_state})
    :ok
  end

  # Server callbacks

  @impl GenServer
  def init(init_arg), do: {:ok, init_arg, init_arg.auto_shutdown_timeout}

  @impl GenServer
  def handle_call(:report_state, _from, state) do
    {:reply, state, state, state.auto_shutdown_timeout}
  end

  def handle_call({:update_state, state}, _from, _state) do
    {:reply, state, state, state.auto_shutdown_timeout}
  end

  @impl GenServer
  def handle_cast({:update_state, state}, _state) do
    {:noreply, state, state.auto_shutdown_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    {:noreply, state, state.auto_shutdown_timeout}
  end
end
