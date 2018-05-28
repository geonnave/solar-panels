defmodule SolarPanels do
  require Logger

  def now_unix do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end
