defmodule SolarPanelsWeb.SensorReadingsController do
  use SolarPanelsWeb, :controller

  def create(conn, %{"id" => panel_id} = params) do
    panel_data = %{
      id: panel_id,
      current: params["current"],
      voltage: params["voltage"],
      timestamp: params["timestamp"]
    }

    SolarPanels.Remote.new_reading(panel_id, panel_data)

    json(conn, panel_data)
  end
end
