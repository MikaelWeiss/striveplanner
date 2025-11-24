defmodule StrivePlanner.Blog.BlogPost do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :excerpt, :string
    field :tags, {:array, :string}, default: []
    field :published_at, :utc_datetime
    field :status, :string, default: "draft"
    field :sent_to_subscribers, :boolean, default: false
    field :featured_image, :string
    field :images, {:array, :string}, default: []
    field :meta_description, :string
    field :view_count, :integer, default: 0
    field :email_sent_at, :utc_datetime
    field :scheduled_email_for, :utc_datetime
    field :email_recipient_count, :integer, default: 0

    belongs_to :author, StrivePlanner.Accounts.User
    has_many :comments, StrivePlanner.Blog.Comment
    has_many :email_deliveries, StrivePlanner.Newsletter.EmailDelivery
    has_many :subscribers, through: [:email_deliveries, :subscriber]

    timestamps()
  end

  @doc false
  def changeset(blog_post, attrs) do
    blog_post
    |> cast(attrs, [
      :title,
      :slug,
      :content,
      :excerpt,
      :tags,
      :published_at,
      :status,
      :author_id,
      :featured_image,
      :images,
      :meta_description,
      :scheduled_email_for
    ])
    |> validate_required([:title, :content])
    |> generate_slug()
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug)
    |> validate_inclusion(:status, ["draft", "published"])
    |> validate_scheduled_email_for()
  end

  defp validate_scheduled_email_for(changeset) do
    case get_change(changeset, :scheduled_email_for) do
      nil ->
        changeset

      scheduled_time ->
        if DateTime.compare(scheduled_time, DateTime.utc_now()) == :gt do
          changeset
        else
          add_error(changeset, :scheduled_email_for, "must be in the future")
        end
    end
  end

  defp generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        title = get_field(changeset, :title)

        if title do
          slug =
            title
            |> String.downcase()
            |> String.replace(~r/[^a-z0-9\s-]/, "")
            |> String.replace(~r/\s+/, "-")
            |> String.trim("-")

          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
