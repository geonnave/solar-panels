defmodule SolarPanels.Remote do
  def new_reading(panel_id, panel_data) do
    # verify that panel_id exists / is valid
    SolarPanelsWeb.Endpoint.broadcast! "panels:aggregated", "value:#{panel_id}", panel_data
  end
end
