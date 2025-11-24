defmodule StrivePlanner.Repo.Migrations.CreateEmailDeliveries do
  use Ecto.Migration

  def change do
    create table(:email_deliveries) do
      add :sent_at, :utc_datetime, null: false
      add :subscriber_id, references(:subscribers, on_delete: :delete_all), null: false
      add :blog_post_id, references(:blog_posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:email_deliveries, [:subscriber_id])
    create index(:email_deliveries, [:blog_post_id])
    create unique_index(:email_deliveries, [:subscriber_id, :blog_post_id])
  end
end
