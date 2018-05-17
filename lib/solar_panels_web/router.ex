defmodule SolarPanelsWeb.Router do
  use SolarPanelsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SolarPanelsWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", SolarPanelsWeb do
    pipe_through :api

    post "/solar_panels/:id/sensor_readings", SensorReadingsController, :create
  end
end
