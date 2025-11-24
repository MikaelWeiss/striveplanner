defmodule StrivePlanner.Newsletter do
  @moduledoc """
  The Newsletter context.
  """

  import Ecto.Query, warn: false
  alias StrivePlanner.Repo
  alias StrivePlanner.Newsletter.Subscriber

  @doc """
  Creates a new subscriber.
  """
  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a subscriber by email.
  """
  def get_subscriber_by_email(email) do
    Repo.get_by(Subscriber, email: email)
  end

  @doc """
  Checks if an email is already subscribed.
  """
  def email_subscribed?(email) do
    Repo.exists?(from s in Subscriber, where: s.email == ^email)
  end

  @doc """
  Generates a verification token and stores it for a subscriber.
  """
  def generate_verification_token(subscriber) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    expires_at = DateTime.add(DateTime.utc_now(), 24 * 3600, :second)

    subscriber
    |> Subscriber.verification_changeset(%{
      verification_token: token,
      verification_token_expires_at: expires_at
    })
    |> Repo.update()
    |> case do
      {:ok, subscriber} -> {:ok, subscriber, token}
      error -> error
    end
  end

  @doc """
  Verifies a subscriber using their verification token.
  """
  def verify_subscriber(token) do
    now = DateTime.utc_now()

    # Fetch all unverified subscribers with active tokens (prevents timing attacks)
    query =
      from s in Subscriber,
        where:
          not is_nil(s.verification_token) and
            s.verification_token_expires_at > ^now and
            s.verified == false

    subscribers = Repo.all(query)

    # Use constant-time comparison to find matching token
    subscriber =
      Enum.find(subscribers, fn s ->
        Plug.Crypto.secure_compare(s.verification_token, token)
      end)

    case subscriber do
      nil ->
        {:error, :invalid_or_expired_token}

      subscriber ->
        subscriber
        |> Subscriber.changeset(%{verified: true})
        |> Repo.update()
    end
  end

  @doc """
  Returns the list of subscribers with email delivery count.
  Each subscriber will have an `emails_received_count` virtual field.
  """
  def list_subscribers do
    from(s in Subscriber,
      left_join: ed in assoc(s, :email_deliveries),
      group_by: s.id,
      select: %{
        s
        | emails_received_count: count(ed.id)
      }
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of verified and subscribed subscribers.
  """
  def list_verified_subscribed_subscribers do
    from(s in Subscriber,
      where: s.verified == true and s.subscription_status == "subscribed"
    )
    |> Repo.all()
  end

  @doc """
  Gets a single subscriber by ID.

  Returns the subscriber if found, nil otherwise.
  """
  def get_subscriber(id), do: Repo.get(Subscriber, id)

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.
  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  @doc """
  Updates a subscriber.
  """
  def update_subscriber(subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscriber.
  """
  def delete_subscriber(subscriber) do
    Repo.delete(subscriber)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.
  """
  def change_subscriber(subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end

  @doc """
  Unsubscribes a subscriber by setting their subscription_status to "unsubscribed".

  This operation is idempotent - calling it multiple times has the same effect.
  """
  def unsubscribe(subscriber) do
    subscriber
    |> Subscriber.changeset(%{subscription_status: "unsubscribed"})
    |> Repo.update()
  end
end
