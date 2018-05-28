defmodule SolarPanelsWeb.PageController do
  use SolarPanelsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
