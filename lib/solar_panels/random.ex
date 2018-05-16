defmodule SolarPanels.Random do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:ok, %{}}
  end

  def handle_info(:broadcast, state) do
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
