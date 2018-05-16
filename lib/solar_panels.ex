defmodule SolarPanels do
  require Logger

  def now_unix do
    DateTime.utc_now |> DateTime.to_unix
  end

  @data_sources %{
    serial: SolarPanels.Serial,
    file: SolarPanels.File,
    random: SolarPanels.Random,
  }
  def configure_data_source(data_source) do
    case @data_sources[data_source] do
      nil ->
        Logger.warn("Invalid data_source")
        :invalid

      module ->
        Logger.info("data_source is now #{module}")
        Application.put_env(:solar_panels, :data_source, module)
    end
  end
end
