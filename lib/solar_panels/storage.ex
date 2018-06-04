defmodule SolarPanels.Storage do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def save(data) do
    GenServer.cast(__MODULE__, {:save, data})
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
    now = %{minute: minute} = DateTime.utc_now()
    {:ok, %{last_saved: %{now | minute: minute - 5}}}
  end

  def handle_cast({:save, data}, %{last_saved: last_saved}) do
    if more_than_five_minutes?(last_saved) or a_day_has_passed?(last_saved) do
      serialize_and_save_to_file(data)
      SolarPanelsWeb.Endpoint.broadcast!("panels:daily", "value", data)

      # serialize_and_save_to_file(data)
      # data_block = serialize_and_add_to_blockchain(data)
      # SolarPanelsWeb.Endpoint.broadcast!("panels:daily", "value", data_block)

      {:noreply, %{last_saved: DateTime.utc_now()}}
    else
      {:noreply, %{last_saved: last_saved}}
    end
  end

  def serialize_and_add_to_blockchain(data) do
    data_socket = serialize(data, :socket)
    SolarPanels.Blockchain.add_block(data_socket)
  end

  def serialize_and_save_to_file(data) do
    data_csv = serialize(data, :csv)
    filename = today_filename()
    Logger.info("Saving #{inspect(data_csv)} to file #{filename}")
    save_to_file(data_csv, filename)
  end

  def save_to_file(data, filename) do
    Path.join(:code.priv_dir(:solar_panels), filename)
    |> File.open([:append], fn file ->
      IO.write(file, data)
    end)
  end

  def serialize(%{"timestamp" => ts, "current" => c, "voltage" => v}, :csv) do
    "#{ts},#{as_string(c)},#{as_string(v)}\n"
  end

  def serialize(%{"timestamp" => ts, "current" => c, "voltage" => v}, :socket) do
    "#{as_string(v)} #{as_string(c)} #{ts} "
  end

  def today_filename() do
    "readings_#{Date.utc_today() |> Date.to_string()}.csv"
  end

  @five_minutes 60 * 5
  def more_than_five_minutes?(last_saved) do
    DateTime.diff(DateTime.utc_now(), last_saved) > @five_minutes
  end

  def a_day_has_passed?(last_saved) do
    DateTime.utc_now.day != last_saved.day
  end

  def as_string(float) do
    :erlang.float_to_binary(float, decimals: 16)
  end

  def as_float(binary) do
    :erlang.binary_to_float(binary)
  end
end
