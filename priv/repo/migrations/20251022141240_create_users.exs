defmodule StrivePlanner.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :verified, :boolean, default: false, null: false
      add :role, :string, default: "user", null: false
      add :magic_link_token, :string
      add :magic_link_expires_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:magic_link_token])
  end
end
