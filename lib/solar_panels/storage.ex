defmodule SolarPanels.Storage do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def save_to_file(data) do
    GenServer.cast __MODULE__, {:save_to_file, data}
  end

  def read_from_file do
    Path.join(:code.priv_dir(:solar_panels), today_filename())
    |> File.read()
    |> case do
      {:ok, contents} ->
        contents
        |> String.split("\n")
        |> Enum.reduce([], fn x, acc ->
          case String.split(x, ",") do
            [ts, c, v] ->
              data = %{"timestamp" => ts, "current" => c, "voltage" => v}
              [data | acc]
            
            _ ->
              acc
          end
        end)
    end
  end

  def init(_opts) do
    {:ok, %{last_saved: Time.utc_now}}
  end

  def handle_cast({:save_to_file, data}, %{last_saved: last_saved}) do
    if more_than_five_minutes?(last_saved) do
      SolarPanelsWeb.Endpoint.broadcast! "panels:daily", "value", data
      data = serialize(data)
      filename = today_filename()
      Logger.info("Saving #{inspect data} to file #{filename}")

      Path.join(:code.priv_dir(:solar_panels), filename)
      |> File.open([:append], fn file ->
        IO.write(file, data)
      end)

      {:noreply, %{last_saved: Time.utc_now}}
    else
      {:noreply, %{last_saved: last_saved}}
    end
  end

  def serialize(%{"timestamp" => ts, "current" => c, "voltage" => v}) do
    c = :erlang.float_to_binary c, decimals: 16
    v = :erlang.float_to_binary v, decimals: 16
    "#{ts},#{c},#{v}\n"
  end

  def today_filename() do
    "readings_#{Date.utc_today |> Date.to_string}.csv"
  end

  def more_than_five_minutes?(last_saved) do
    Time.diff(Time.utc_now, last_saved) > 60 * 5
  end
end
