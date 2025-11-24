defmodule StrivePlanner.Accounts do
  @moduledoc """
  The Accounts context for managing users and authentication.
  """

  import Ecto.Query, warn: false
  alias StrivePlanner.Repo
  alias StrivePlanner.Accounts.User

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by ID.
  """
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc """
  Creates a new user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Checks if a user is an admin.
  """
  def admin?(user) do
    user.role == "admin"
  end

  @doc """
  Generates a magic link token for admin login and stores it for a user.
  Returns {:ok, user, token} on success.
  """
  def generate_admin_magic_link(email) do
    case get_user_by_email(email) do
      nil ->
        {:error, :user_not_found}

      user ->
        if admin?(user) do
          token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
          expires_at = DateTime.add(DateTime.utc_now(), 15 * 60, :second)

          user
          |> User.magic_link_changeset(%{
            magic_link_token: token,
            magic_link_expires_at: expires_at
          })
          |> Repo.update()
          |> case do
            {:ok, user} -> {:ok, user, token}
            error -> error
          end
        else
          {:error, :not_admin}
        end
    end
  end

  @doc """
  Verifies an admin magic link token and returns the user if valid.
  """
  def verify_admin_magic_link(token) do
    now = DateTime.utc_now()

    # Fetch all admins with active tokens (prevents timing attacks)
    query =
      from u in User,
        where:
          not is_nil(u.magic_link_token) and
            u.magic_link_expires_at > ^now and
            u.role == "admin"

    users = Repo.all(query)

    # Use constant-time comparison to find matching token
    user =
      Enum.find(users, fn u ->
        Plug.Crypto.secure_compare(u.magic_link_token, token)
      end)

    case user do
      nil ->
        {:error, :invalid_or_expired_token}

      user ->
        # Clear the token after successful verification using a direct changeset
        user
        |> Ecto.Changeset.change(%{
          magic_link_token: nil,
          magic_link_expires_at: nil
        })
        |> Repo.update()
        |> case do
          {:ok, user} -> {:ok, user}
          error -> error
        end
    end
  end
end
