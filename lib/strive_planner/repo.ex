defmodule StrivePlanner.Repo do
  use Ecto.Repo,
    otp_app: :strive_planner,
    adapter: Ecto.Adapters.Postgres
end
