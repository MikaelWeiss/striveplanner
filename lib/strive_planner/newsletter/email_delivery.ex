defmodule StrivePlanner.Newsletter.EmailDelivery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "email_deliveries" do
    field :sent_at, :utc_datetime

    belongs_to :subscriber, StrivePlanner.Newsletter.Subscriber
    belongs_to :blog_post, StrivePlanner.Blog.BlogPost

    timestamps()
  end

  @doc false
  def changeset(email_delivery, attrs) do
    email_delivery
    |> cast(attrs, [:sent_at, :subscriber_id, :blog_post_id])
    |> validate_required([:sent_at, :subscriber_id, :blog_post_id])
    |> foreign_key_constraint(:subscriber_id)
    |> foreign_key_constraint(:blog_post_id)
  end
end
