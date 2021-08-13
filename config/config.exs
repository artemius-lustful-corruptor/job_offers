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
config :phoenix, :json_library, Poison
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
  ]
