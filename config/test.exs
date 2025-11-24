import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :strive_planner, StrivePlanner.Repo,
  username: "mikaelweiss",
  password: "mikaelweiss",
  hostname: "localhost",
  database: "strive_planner_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :strive_planner, StrivePlannerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vaft/EtivBw+RdM/eIC9i+KXzYxCeNn2pgwci3GSWp0mhoZ1JX/NVGCStc5v5wQw",
  server: false

# In test we don't send emails
config :strive_planner, StrivePlanner.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Oban for testing (disable background processing)
config :strive_planner, Oban,
  testing: :manual,
  queues: false,
  plugins: false
