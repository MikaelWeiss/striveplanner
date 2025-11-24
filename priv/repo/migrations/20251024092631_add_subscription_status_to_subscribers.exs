defmodule StrivePlanner.Repo.Migrations.AddSubscriptionStatusToSubscribers do
  use Ecto.Migration

  def change do
    alter table(:subscribers) do
      add :subscription_status, :string, default: "subscribed", null: false
    end

    create index(:subscribers, [:subscription_status])
    create index(:subscribers, [:verified, :subscription_status])
  end
end
