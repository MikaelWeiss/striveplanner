defmodule StrivePlanner.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :verified, :boolean, default: false
    field :role, :string, default: "user"
    field :magic_link_token, :string
    field :magic_link_expires_at, :utc_datetime

    has_many :comments, StrivePlanner.Blog.Comment

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :verified, :role])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> unique_constraint(:email)
    |> validate_inclusion(:role, ["user", "admin"])
  end

  @doc false
  def magic_link_changeset(user, attrs) do
    user
    |> cast(attrs, [:magic_link_token, :magic_link_expires_at])
    |> validate_required([:magic_link_token, :magic_link_expires_at])
  end
end
