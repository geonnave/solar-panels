defmodule SolarPanels do
  def broadcast do
    SolarPanelsWeb.Endpoint.broadcast! "room:lobby", "value", %{"current" => 0.083333, "voltage" => 0.120939}
  end
end
