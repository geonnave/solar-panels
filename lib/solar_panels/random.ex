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
    Logger.debug "will broadcast"
    SolarPanelsWeb.Endpoint.broadcast! "panels:random", "value", %{
      "current" => %{"value" => :rand.uniform(), "timestamp" => SolarPanels.now_unix()},
      "voltage" => %{"value" => :rand.uniform(), "timestamp" => SolarPanels.now_unix()}
    }
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:noreply, state}
  end
end
