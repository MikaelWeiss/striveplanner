defmodule StrivePlanner.Repo.Migrations.AddScheduledEmailIndexToBlogPosts do
  use Ecto.Migration

  def change do
    create index(:blog_posts, [:scheduled_email_for, :sent_to_subscribers])
  end
end
