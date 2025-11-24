defmodule StrivePlanner.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :blog_post, StrivePlanner.Blog.BlogPost
    belongs_to :user, StrivePlanner.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :blog_post_id, :user_id])
    |> validate_required([:content, :blog_post_id, :user_id])
    |> validate_length(:content, min: 1, max: 5000)
    |> foreign_key_constraint(:blog_post_id)
    |> foreign_key_constraint(:user_id)
  end
end
