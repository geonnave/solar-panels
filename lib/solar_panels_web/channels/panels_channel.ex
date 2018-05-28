defmodule SolarPanelsWeb.PanelsChannel do
  use SolarPanelsWeb, :channel

  def join("panels:daily", _payload, socket) do
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

  def handle_in("get_daily", payload, socket) do
    Task.start(fn ->
      # {_, readings} =
      #   SolarPanels.Storage.read_from_file
      #   |> Enum.reduce({0, []}, fn x, {i, acc} ->
      #     if i > 10 do
      #       {0, [x | acc]}
      #     else
      #       {i + 1, acc}
      #     end
      #   end)

      for reading <- Enum.reverse(SolarPanels.Storage.read_from_file()) do
        # for reading <- readings do
        # Process.sleep(200)
        SolarPanelsWeb.Endpoint.broadcast!("panels:daily", "value", reading)
      end
    end)

    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
