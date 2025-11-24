defmodule StrivePlanner.AccountsFixtures do
  @moduledoc """
  This module defines test fixtures for Accounts context.

  Fixtures create reusable test data for user and admin authentication testing.
  All fixtures use unique emails to prevent conflicts in async tests.
  """

  alias StrivePlanner.Accounts

  @doc """
  Creates a regular user with a unique email.

  ## Examples

      iex> user = user_fixture()
      iex> user.role
      "user"

      iex> user = user_fixture(%{email: "custom@example.com"})
      iex> user.email
      "custom@example.com"

  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user-#{System.unique_integer([:positive])}@example.com",
        role: "user"
      })
      |> Accounts.create_user()

    user
  end

  @doc """
  Creates an admin user.

  ## Examples

      iex> admin = admin_fixture()
      iex> admin.role
      "admin"

  """
  def admin_fixture(attrs \\ %{}) do
    attrs
    |> Map.put(:role, "admin")
    |> user_fixture()
  end

  @doc """
  Creates an admin user with a valid magic link token.

  ## Examples

      iex> admin = admin_with_magic_link_fixture()
      iex> admin.magic_link_token
      "valid-token-..."

  """
  def admin_with_magic_link_fixture(attrs \\ %{}) do
    admin = admin_fixture(attrs)

    {:ok, updated_admin, _token} = Accounts.generate_admin_magic_link(admin.email)

    updated_admin
  end
end
