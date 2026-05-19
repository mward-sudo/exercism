defmodule LogLevel do
  def to_label(0 = _log_code, false = _legacy?), do: :trace
  def to_label(1 = _log_code, _legacy?), do: :debug
  def to_label(2 = _log_code, _legacy?), do: :info
  def to_label(3 = _log_code, _legacy?), do: :warning
  def to_label(4 = _log_code, _legacy?), do: :error
  def to_label(5 = _log_code, false = _legacy?), do: :fatal
  def to_label(_log_code, _legacy?), do: :unknown

  def alert_recipient(level, legacy?) do
    case to_label(level, legacy?) do
      log_label when log_label in [:error, :fatal] ->
        :ops

      :unknown when legacy? ->
        :dev1

      :unknown ->
        :dev2

      _ ->
        nil
    end
  end
end
