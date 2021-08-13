# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
config :logger, :console,
  level: :info,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

config :job_offers,
  professions_csv: "technical-test-professions.csv",
  jobs_csv: "technical-test-jobs.csv",
  result_map: %{
    "Europe" => [],
    "Asia" => [],
    "Africa" => [],
    "Oceania" => [],
    "South America" => [],
    "North America" => [],
    "Antarctica" => []
  },
  continents: [
    {"Europe", [{-5, 37}, {-7, 75}, {61, 52}, {66, 76}]},
    {"Asia", [{44, 15}, {26, 39}, {169, 78}, {105, -1}]},
    {"Africa", [{-17, 35}, {-16, -35}, {45, 32}, {22, 35}]},
    {"Oceania", [{103, -8}, {106, -43}, {174, -45}, {172, 3}]},
    {"South America", [{-95, 10}, {-85, -55}, {-102, 8}, {-32, 12}]},
    {"North America", [{-85, 2}, {-171, 63}, {-66, 75}, {-69, 12}]}
  ],
  earth_radius: 6371

# Configures the endpoint
config :job_offers_service, JobOffersServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5eWBADigmcUlWCk8WThah8OzFDioZiW+E1Odot4PV6QWmVTviW0dedaE1gKLETOr",
  render_errors: [view: JobOffersServiceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: JobOffersService.PubSub,
  live_view: [signing_salt: "9RqhYv+L"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
