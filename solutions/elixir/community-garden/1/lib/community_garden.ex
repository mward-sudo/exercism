defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(opts \\ []), do: Agent.start(fn -> [] end, opts)

  @spec list_registrations(pid) :: [Plot.t()]
  @doc """
  Lists all plots in the registry where registered_to is not nil
  """
  def list_registrations(pid),
    do: Agent.get(pid, &for(plot <- &1, registered_plot?(plot), do: plot))

  def register(pid, register_to) do
    new_plot_id = get_new_plot_id(pid)
    new_plot = %Plot{plot_id: new_plot_id, registered_to: register_to}

    :ok = Agent.update(pid, fn registrations -> [new_plot | registrations] end)

    new_plot
  end

  @doc """
  Takes
  """
  def release(pid, plot_id) do
    :ok = Agent.update(pid, &for(plot <- &1, do: maybe_release_plot(plot, plot_id)))
  end

  def get_registration(pid, plot_id) do
    list_registrations(pid)
    |> Enum.find(&(&1.plot_id == plot_id))
    |> case do
      nil -> {:not_found, "plot is unregistered"}
      plot -> plot
    end
  end

  defp maybe_release_plot(plot, plot_id) when plot.id == plot_id,
    do: %Plot{plot | registered_to: nil}

  defp maybe_release_plot(plot, _), do: plot

  defp get_new_plot_id(pid), do: Agent.get(pid, & &1) |> length() |> Kernel.+(1)

  defp registered_plot?(plot), do: plot.registered_to != nil
end
