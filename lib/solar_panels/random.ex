defmodule SolarPanels.Random do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:ok, %{}}
  end

  def handle_info(:broadcast, state) do
    IO.puts "will broadcast"
    SolarPanelsWeb.Endpoint.broadcast! "room:lobby", "value", %{
      "current" => %{"value" => :rand.uniform(), "timestamp" => now_unix()},
      "voltage" => %{"value" => :rand.uniform(), "timestamp" => now_unix()}
    }
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:noreply, state}
  end

  def now_unix do
    DateTime.utc_now |> DateTime.to_unix
  end
end