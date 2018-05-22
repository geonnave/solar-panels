defmodule SolarPanels.Blockchain do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def add_transaction(data) do
    GenServer.cast __MODULE__, {:add_transaction, data}
  end

  def init(_) do
    socket_opts = [:binary, active: false, nodelay: true, packet: :raw]
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 1735, socket_opts)
    Logger.info "Connected to socket #{inspect socket}"
    {:ok, socket}
  end

  def handle_cast({:add_transaction, data}, socket) do
    Logger.debug "Transaction data is #{data}"
    IO.inspect :gen_tcp.send(socket, data)
    {:noreply, socket}
  end
end
