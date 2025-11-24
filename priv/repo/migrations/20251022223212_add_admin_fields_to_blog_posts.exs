defmodule StrivePlanner.Repo.Migrations.AddAdminFieldsToBlogPosts do
  use Ecto.Migration

  def change do
    alter table(:blog_posts) do
      add :featured_image, :string
      add :images, {:array, :string}, default: []
      add :meta_description, :text
      add :view_count, :integer, default: 0, null: false
      add :email_sent_at, :utc_datetime
      add :scheduled_email_for, :utc_datetime
      add :email_recipient_count, :integer, default: 0, null: false
    end
  end
end
