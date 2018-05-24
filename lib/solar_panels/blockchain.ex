defmodule SolarPanels.Blockchain do
  require Logger

  def add_transaction(data) do
    Logger.debug "Transaction data is #{data}"
    case :gen_tcp.connect('127.0.0.1', 1735, [:binary, active: false]) do
      {:ok, socket} ->
        :gen_tcp.send(socket, data)
        :gen_tcp.close(socket)
      {:error, reason} ->
        Logger.warn "Could not connect to 127.0.0.1:1735 (#{inspect reason})"
    end
  end
end
