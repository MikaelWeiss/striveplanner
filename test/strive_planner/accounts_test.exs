defmodule StrivePlanner.AccountsTest do
  use StrivePlanner.DataCase, async: true

  alias StrivePlanner.Accounts

  import StrivePlanner.AccountsFixtures

  describe "get_user_by_email/1" do
    test "returns user when email exists" do
      user = user_fixture(%{email: "exists@example.com"})

      assert found = Accounts.get_user_by_email("exists@example.com")
      assert found.id == user.id
    end

    test "returns nil when email does not exist" do
      assert Accounts.get_user_by_email("nonexistent@example.com") == nil
    end
  end

  describe "get_user/1" do
    test "returns user when ID exists" do
      user = user_fixture()

      assert found = Accounts.get_user(user.id)
      assert found.id == user.id
    end

    test "returns nil when ID does not exist" do
      assert Accounts.get_user(999_999) == nil
    end
  end

  describe "create_user/1" do
    test "creates user with valid attributes" do
      attrs = %{email: "newuser@example.com"}

      assert {:ok, user} = Accounts.create_user(attrs)
      assert user.email == "newuser@example.com"
      assert user.role == "user"
    end

    test "returns error with invalid email" do
      attrs = %{email: "invalid"}

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "returns error with duplicate email" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{email: user.email})
    end

    test "defaults role to user" do
      {:ok, user} = Accounts.create_user(%{email: "default@example.com"})

      assert user.role == "user"
    end
  end

  describe "admin?/1" do
    test "returns true for admin user" do
      admin = admin_fixture()

      assert Accounts.admin?(admin) == true
    end

    test "returns false for regular user" do
      user = user_fixture()

      assert Accounts.admin?(user) == false
    end
  end

  describe "generate_admin_magic_link/1" do
    test "generates token for admin user" do
      admin = admin_fixture(%{email: "admin@example.com"})

      assert {:ok, updated_admin, token} =
               Accounts.generate_admin_magic_link("admin@example.com")

      assert is_binary(token)
      assert byte_size(token) > 0
      assert updated_admin.magic_link_token == token
      assert updated_admin.id == admin.id
    end

    test "returns error for non-existent user" do
      assert {:error, :user_not_found} =
               Accounts.generate_admin_magic_link("nonexistent@example.com")
    end

    test "returns error for non-admin user" do
      user = user_fixture(%{email: "user@example.com"})

      assert {:error, :not_admin} = Accounts.generate_admin_magic_link(user.email)
    end

    test "sets 15-minute expiration" do
      admin = admin_fixture()

      assert {:ok, updated_admin, _token} =
               Accounts.generate_admin_magic_link(admin.email)

      # Verify expiration is approximately 15 minutes from now
      now = DateTime.utc_now()
      expires_at = updated_admin.magic_link_expires_at

      diff_seconds = DateTime.diff(expires_at, now, :second)

      # Allow for slight timing differences (14.9 to 15.1 minutes)
      assert diff_seconds >= 15 * 60 - 10
      assert diff_seconds <= 15 * 60 + 10
    end

    test "generates unique token" do
      admin = admin_fixture()

      {:ok, _admin1, token1} = Accounts.generate_admin_magic_link(admin.email)

      # Get fresh admin from DB
      admin = Accounts.get_user_by_email(admin.email)
      {:ok, _admin2, token2} = Accounts.generate_admin_magic_link(admin.email)

      assert token1 != token2
    end
  end

  describe "verify_admin_magic_link/1" do
    test "verifies admin with valid token" do
      admin = admin_with_magic_link_fixture()

      assert {:ok, verified_admin} =
               Accounts.verify_admin_magic_link(admin.magic_link_token)

      assert verified_admin.id == admin.id
    end

    test "returns error with expired token" do
      admin = admin_fixture()

      # Generate token but manually set it as expired
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      expired_at = DateTime.add(DateTime.utc_now(), -3600, :second)

      admin
      |> StrivePlanner.Accounts.User.magic_link_changeset(%{
        magic_link_token: token,
        magic_link_expires_at: expired_at
      })
      |> Repo.update!()

      assert {:error, :invalid_or_expired_token} =
               Accounts.verify_admin_magic_link(token)
    end

    test "returns error with invalid token" do
      assert {:error, :invalid_or_expired_token} =
               Accounts.verify_admin_magic_link("invalid-token-12345")
    end

    test "clears token after successful verification" do
      admin = admin_with_magic_link_fixture()
      token = admin.magic_link_token

      {:ok, verified_admin} = Accounts.verify_admin_magic_link(token)

      # Token should be cleared
      assert verified_admin.magic_link_token == nil
      assert verified_admin.magic_link_expires_at == nil

      # Verify persistence
      found = Accounts.get_user(admin.id)
      assert found.magic_link_token == nil
      assert found.magic_link_expires_at == nil
    end

    test "returns error for non-admin user" do
      user = user_fixture()

      # Try to set magic link for non-admin (manually)
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      expires_at = DateTime.add(DateTime.utc_now(), 900, :second)

      user
      |> StrivePlanner.Accounts.User.magic_link_changeset(%{
        magic_link_token: token,
        magic_link_expires_at: expires_at
      })
      |> Repo.update!()

      # Should not verify non-admin
      assert {:error, :invalid_or_expired_token} =
               Accounts.verify_admin_magic_link(token)
    end
  end
end
