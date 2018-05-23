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
    payload = %{
      "timestamp" => SolarPanels.now_unix(),
      "current" => :rand.uniform(),
      "voltage" => :rand.uniform(),
    }
    SolarPanelsWeb.Endpoint.broadcast! "panels:real", "value", payload
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:noreply, state}
  end
end
