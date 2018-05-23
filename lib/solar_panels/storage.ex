defmodule SolarPanels.Storage do
  def save_to_file(data) do
    filename = Path.join(:code.priv_dir(:solar_panels), "readings_#{Date.utc_today |> Date.to_string}.csv")
    File.open(filename, [:append], fn file ->
      IO.write(file, serialize(data))
    end)
  end

  def serialize(%{"timestamp" => ts, "current" => c, "voltage" => v}) do
    c = :erlang.float_to_binary c, decimals: 16
    v = :erlang.float_to_binary v, decimals: 16
    "#{ts},#{c},#{v}\n"
  end
end
