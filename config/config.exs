# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :solar_panels, SolarPanelsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "orXJbywPofMexWbasK1jEhb6vpeaDHwEuUlA0lWqBVIQ/fbgaA3hKDY7sWESEQWg",
  render_errors: [view: SolarPanelsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SolarPanels.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :solar_panels,
  port: "ttyUSB0",
  data_source: SolarPanels.Random

# Configures Elixir's Logger
config :logger, :level, :debug
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:module]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
