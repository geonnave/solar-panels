defmodule SolarPanels.Serial do
  use GenServer
  require Logger

  def start_link(opts \\ [port: "ttyUSB0"]) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init([port: port]) do
    case Nerves.UART.enumerate do
      %{^port => serial_port} ->
        Logger.info("Found port #{serial_port}")
        {:ok, serial_port}
      _ ->
        {:stop, "port not available"}
    end
  end
end
