defmodule SolarPanels.Storage do
  def save_to_file(data) do
    File.write!("filename", data)
  end
end
