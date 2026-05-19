defmodule LogLevel do
  def to_label(log_code, legacy?) do
    cond do
      log_code == 0 and not legacy? -> :trace
      log_code == 1 -> :debug
      log_code == 2 -> :info
      log_code == 3 -> :warning
      log_code == 4 -> :error
      log_code == 5 and not legacy? -> :fatal
      true -> :unknown
    end
  end

  def alert_recipient(level, legacy?) do
    log_label = to_label(level, legacy?)

    cond do
      log_label in [:error, :fatal] -> :ops
      log_label == :unknown and legacy? -> :dev1
      log_label == :unknown -> :dev2
      true -> nil
    end
  end
end
