defmodule SolarPanels.Serial do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def close_port do
    GenServer.cast __MODULE__, :close_port
  end

  def open_port do
    GenServer.cast __MODULE__, :open_port
  end

  def init(_opts) do
    case find_and_open_port() do
      {:ok, port_info} ->
        {:ok, port_info}

      _ ->
        Logger.info "Serial started, but serial port was not found."
        {:ok, nil}
    end
  end

  def handle_info({:nerves_uart, _, {:error, _}}, state) do
    Logger.warn "Serial disconnected. Switchting to random."
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _, data}, state) do
    Logger.debug "will broadcast #{data}"
    case Poison.decode(data) do
      {:ok, data} ->
        payload = put_in(data, ["timestamp"], SolarPanels.now_unix())
        SolarPanelsWeb.Endpoint.broadcast! "panels:real", "value", payload
        SolarPanels.Storage.save_to_file(data)

      {:error, reason} ->
        Logger.warn "Could not parse data because of reason #{inspect reason}"
    end
    Process.send_after(__MODULE__, :broadcast, 3_000)
    {:noreply, state}
  end

  def handle_info(other, state) do
    Logger.debug "received #{inspect other} with state #{inspect state}"
    {:noreply, state}
  end

  def handle_cast(:close_port, {_port, pid}) do
    Nerves.UART.close(pid)
    {:noreply, nil}
  end

  def handle_cast(:open_port, _state) do
    case find_and_open_port() do
      {:ok, port_info} ->
        {:noreply, port_info}

      _ ->
        Logger.info "Could not find and open port"
        {:noreply, nil}
    end
  end

  def find_and_open_port do
    Nerves.UART.enumerate
    |> find_serial_4292()
    |> case do
      [{port, _info}] ->
        Logger.info("Found port at #{port}")
        {:ok, {port, open_port(port)}}

      [] ->
        {:error, "port not available"}
      end
  end

  def open_port(port) do
    {:ok, pid} = Nerves.UART.start_link
    Nerves.UART.open(pid, port, speed: 230400, active: false)
    Nerves.UART.configure(pid, active: true, framing: {Nerves.UART.Framing.Line, separator: <<3, 2>>})
    pid
  end

  def find_serial_4292(available_ports) do
    available_ports
    |> Enum.filter(fn {_port, info} ->
      check_vendor_and_product_id(info)
    end)
  end

  def check_vendor_and_product_id(port_info) do
    port_info[:product_id] == 60000 and port_info[:vendor_id] == 4292
  end
end
