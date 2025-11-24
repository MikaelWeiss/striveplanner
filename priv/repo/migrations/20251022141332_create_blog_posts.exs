defmodule StrivePlanner.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :content, :text, null: false
      add :excerpt, :text
      add :tags, {:array, :string}, default: []
      add :published_at, :utc_datetime
      add :status, :string, default: "draft", null: false
      add :sent_to_subscribers, :boolean, default: false, null: false
      add :author_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:blog_posts, [:slug])
    create index(:blog_posts, [:author_id])
    create index(:blog_posts, [:status])
    create index(:blog_posts, [:published_at])
  end
end
