defmodule StrivePlanner.Newsletter.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :email, :string
    field :verified, :boolean, default: false
    field :subscription_status, :string, default: "subscribed"
    field :verification_token, :string
    field :verification_token_expires_at, :utc_datetime
    field :emails_received_count, :integer, virtual: true, default: 0

    has_many :email_deliveries, StrivePlanner.Newsletter.EmailDelivery
    has_many :blog_posts, through: [:email_deliveries, :blog_post]

    timestamps()
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:email, :verified, :subscription_status])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_inclusion(:subscription_status, ["subscribed", "unsubscribed"])
    |> unique_constraint(:email)
  end

  @doc false
  def verification_changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:verification_token, :verification_token_expires_at])
    |> validate_required([:verification_token, :verification_token_expires_at])
  end
end
