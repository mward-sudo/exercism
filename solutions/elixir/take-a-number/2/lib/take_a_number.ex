defmodule TakeANumber do
  @initial_state 0

  def start() do
    spawn(fn -> loop(@initial_state) end)
  end

  defp loop(state) do
    state =
      receive do
        {:report_state, parent_pid} ->
          send(parent_pid, state)

        {:take_a_number, parent_pid} ->
          send(parent_pid, state + 1)

        :stop ->
          exit(:halt)

        _ ->
          state
      end

    loop(state)
  end
end
