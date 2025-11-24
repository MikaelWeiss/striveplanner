defmodule StrivePlanner.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :email, :string, null: false
      add :verified, :boolean, default: false, null: false
      add :verification_token, :string
      add :verification_token_expires_at, :utc_datetime

      timestamps()
    end

    create unique_index(:subscribers, [:email])
    create index(:subscribers, [:verification_token])
  end
end
