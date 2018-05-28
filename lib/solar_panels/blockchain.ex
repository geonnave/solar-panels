defmodule SolarPanels.Blockchain do
  require Logger
  alias SolarPanels.Storage

  @empty_block %{
    "timestamp" => "",
    "current" => "",
    "voltage" => "",
    "hash" => "",
    "prev_hash" => ""
  }

  def add_block(data) do
    Logger.debug("Saving data to blockchain #{data}")

    with {:ok, socket} <- :gen_tcp.connect('127.0.0.1', 1735, [:binary, active: false]) do
      :gen_tcp.send(socket, data)

      data_block =
        case :gen_tcp.recv(socket, 0, 1_000) do
          {:ok, data} ->
            Logger.debug("Saved block is #{data}")
            parse_block(data)

          {:error, _reason} ->
            @empty_block
        end

      :gen_tcp.close(socket)
      data_block
    else
      {:error, reason} ->
        Logger.warn("Could not connect to 127.0.0.1:1735 (#{inspect(reason)})")
        @empty_block
    end
  end

  def parse_block(data_block) do
    case String.split(data_block) do
      [v, c, ts, ch, ph] ->
        %{
          "timestamp" => String.to_integer(ts),
          "current" => Storage.as_float(c),
          "voltage" => Storage.as_float(v),
          "hash" => ch,
          "prev_hash" => ph
        }

      _ ->
        @empty_block
    end
  end
end
