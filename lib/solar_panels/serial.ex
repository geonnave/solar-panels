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
        {:ok, pid} = Nerves.UART.start_link
        Nerves.UART.open(pid, "ttyUSB0", speed: 230400, active: false)
        Nerves.UART.configure(pid, active: true, framing: {Nerves.UART.Framing.Line, separator: <<3, 2>>})

        {:ok, {port, pid}}
      _ ->
        {:stop, "port not available"}
    end
  end

  def handle_info({:nerves_uart, port, data}, state = {port, pid}) do
    if Application.get_env(:solar_panels, :data_source) == __MODULE__ do
      Logger.debug "will broadcast"
      SolarPanelsWeb.Endpoint.broadcast! "room:lobby", "value", %{
        "current" => %{"value" => :rand.uniform(), "timestamp" => SolarPanels.now_unix()},
        "voltage" => %{"value" => :rand.uniform(), "timestamp" => SolarPanels.now_unix()}
      }
      Process.send_after(__MODULE__, :broadcast, 3_000)
    end
    {:noreply, state}
  end
end
