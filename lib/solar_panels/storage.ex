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
    {:ok, %{last_minute_saved: Time.utc_now.minute - 1}}
  end

  def handle_cast({:save_to_file, data}, %{last_minute_saved: last_minute_saved}) do
    if Time.utc_now.minute != last_minute_saved do
      data = serialize(data)
      filename = today_filename()
      Logger.info("Saving #{inspect data} to file #{filename}")

      Path.join(:code.priv_dir(:solar_panels), filename)
      |> File.open([:append], fn file ->
        IO.write(file, data)
      end)

      {:noreply, %{last_minute_saved: Time.utc_now.minute}}
    else
      {:noreply, %{last_minute_saved: last_minute_saved}}
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
end
