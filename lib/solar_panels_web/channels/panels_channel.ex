defmodule SolarPanelsWeb.PanelsChannel do
  use SolarPanelsWeb, :channel

  def join("panels:random", _payload, socket) do
    {:ok, socket}
  end
  def join("panels:real", _payload, socket) do
    {:ok, socket}
  end
  def join("panels:aggregated", _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end