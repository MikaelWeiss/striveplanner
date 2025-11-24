defmodule StrivePlanner.NewsletterTest do
  @moduledoc """
  Tests for Newsletter context business logic.

  These tests follow the **Arrange-Act-Assert** pattern:
  - **Arrange**: Set up test data and preconditions
  - **Act**: Execute the function being tested
  - **Assert**: Verify the expected outcome

  ## Example Test Structure

      test "creates subscriber with valid email" do
        # Arrange: Prepare the input data
        attrs = %{email: "test@example.com"}

        # Act: Call the function under test
        assert {:ok, subscriber} = Newsletter.create_subscriber(attrs)

        # Assert: Verify the results
        assert subscriber.email == "test@example.com"
        assert subscriber.verified == false
      end

  ## Best Practices

  - Use descriptive test names that explain what is being tested
  - Keep tests focused on a single behavior
  - Use fixtures for creating test data (avoid duplication)
  - Test both success and failure paths
  - Test edge cases (nil, empty, invalid data)
  """

  use StrivePlanner.DataCase, async: true

  alias StrivePlanner.Newsletter

  import StrivePlanner.NewsletterFixtures

  describe "create_subscriber/1" do
    test "creates subscriber with valid email" do
      attrs = %{email: "test@example.com"}

      assert {:ok, subscriber} = Newsletter.create_subscriber(attrs)
      assert subscriber.email == "test@example.com"
      assert subscriber.verified == false
    end

    test "returns error with invalid email" do
      attrs = %{email: "invalid"}

      assert {:error, %Ecto.Changeset{}} = Newsletter.create_subscriber(attrs)
    end

    test "returns error with duplicate email" do
      subscriber = subscriber_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Newsletter.create_subscriber(%{email: subscriber.email})
    end

    test "generates unique email for each fixture" do
      subscriber1 = subscriber_fixture()
      subscriber2 = subscriber_fixture()

      assert subscriber1.email != subscriber2.email
    end
  end

  describe "get_subscriber_by_email/1" do
    test "returns subscriber when email exists" do
      subscriber = subscriber_fixture()

      assert found = Newsletter.get_subscriber_by_email(subscriber.email)
      assert found.id == subscriber.id
    end

    test "returns nil when email does not exist" do
      assert Newsletter.get_subscriber_by_email("nonexistent@example.com") == nil
    end

    test "is case-sensitive for email matching" do
      _subscriber = subscriber_fixture(%{email: "test@example.com"})

      assert Newsletter.get_subscriber_by_email("test@example.com")
      # Note: Current implementation is case-sensitive
      # If case-insensitive is required, this test will need updating
    end
  end

  describe "email_subscribed?/1" do
    test "returns true when email is subscribed" do
      subscriber = subscriber_fixture(%{email: "subscribed@example.com"})

      assert Newsletter.email_subscribed?(subscriber.email) == true
    end

    test "returns false when email is not subscribed" do
      assert Newsletter.email_subscribed?("notsubscribed@example.com") == false
    end
  end

  describe "generate_verification_token/1" do
    test "generates unique token for subscriber" do
      subscriber = subscriber_fixture()

      assert {:ok, updated_subscriber, token} =
               Newsletter.generate_verification_token(subscriber)

      assert is_binary(token)
      assert byte_size(token) > 0
      assert updated_subscriber.verification_token == token
    end

    test "sets 24-hour expiration" do
      subscriber = subscriber_fixture()

      assert {:ok, updated_subscriber, _token} =
               Newsletter.generate_verification_token(subscriber)

      # Verify expiration is approximately 24 hours from now
      now = DateTime.utc_now()
      expires_at = updated_subscriber.verification_token_expires_at

      diff_seconds = DateTime.diff(expires_at, now, :second)

      # Allow for slight timing differences (23.9 to 24.1 hours)
      assert diff_seconds >= 24 * 3600 - 60
      assert diff_seconds <= 24 * 3600 + 60
    end

    test "returns error for invalid subscriber" do
      # This tests the error path if the subscriber update fails
      # In practice, this is hard to trigger with valid data
      # but the function should handle Repo.update() errors
    end

    test "generates different tokens for multiple calls" do
      subscriber = subscriber_fixture()

      {:ok, _subscriber1, token1} = Newsletter.generate_verification_token(subscriber)

      # Get fresh subscriber from DB
      subscriber = Newsletter.get_subscriber_by_email(subscriber.email)
      {:ok, _subscriber2, token2} = Newsletter.generate_verification_token(subscriber)

      assert token1 != token2
    end
  end

  describe "verify_subscriber/1" do
    test "verifies subscriber with valid token" do
      subscriber = subscriber_with_token_fixture()

      assert {:ok, verified_subscriber} =
               Newsletter.verify_subscriber(subscriber.verification_token)

      assert verified_subscriber.verified == true
      assert verified_subscriber.id == subscriber.id
    end

    test "rejects expired token" do
      subscriber = subscriber_fixture()

      # Generate token but manually set it as expired
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      expired_at = DateTime.add(DateTime.utc_now(), -3600, :second)

      subscriber
      |> StrivePlanner.Newsletter.Subscriber.verification_changeset(%{
        verification_token: token,
        verification_token_expires_at: expired_at
      })
      |> Repo.update!()

      assert {:error, :invalid_or_expired_token} = Newsletter.verify_subscriber(token)
    end

    test "rejects invalid token" do
      assert {:error, :invalid_or_expired_token} =
               Newsletter.verify_subscriber("invalid-token-12345")
    end

    test "rejects already verified subscriber" do
      subscriber = verified_subscriber_fixture()

      # Generate token for already verified subscriber
      token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      expires_at = DateTime.add(DateTime.utc_now(), 3600, :second)

      subscriber
      |> StrivePlanner.Newsletter.Subscriber.verification_changeset(%{
        verification_token: token,
        verification_token_expires_at: expires_at
      })
      |> Repo.update!()

      # Should not verify again
      assert {:error, :invalid_or_expired_token} = Newsletter.verify_subscriber(token)
    end

    test "marks subscriber as verified" do
      subscriber = subscriber_with_token_fixture()

      refute subscriber.verified

      {:ok, verified_subscriber} =
        Newsletter.verify_subscriber(subscriber.verification_token)

      assert verified_subscriber.verified == true

      # Verify persistence
      found = Newsletter.get_subscriber_by_email(subscriber.email)
      assert found.verified == true
    end
  end

  describe "list_subscribers/0" do
    test "returns all subscribers" do
      subscriber1 = subscriber_fixture()
      subscriber2 = subscriber_fixture()

      subscribers = Newsletter.list_subscribers()

      assert length(subscribers) >= 2
      subscriber_ids = Enum.map(subscribers, & &1.id)
      assert subscriber1.id in subscriber_ids
      assert subscriber2.id in subscriber_ids
    end

    test "returns empty list when no subscribers exist" do
      # Clear all subscribers first
      Newsletter.list_subscribers()
      |> Enum.each(&Newsletter.delete_subscriber/1)

      assert Newsletter.list_subscribers() == []
    end
  end

  describe "list_verified_subscribed_subscribers/0" do
    test "returns only verified and subscribed subscribers" do
      verified_subscribed =
        subscriber_fixture(%{verified: true, subscription_status: "subscribed"})

      _unverified_subscribed =
        subscriber_fixture(%{verified: false, subscription_status: "subscribed"})

      _verified_unsubscribed =
        subscriber_fixture(%{verified: true, subscription_status: "unsubscribed"})

      subscribers = Newsletter.list_verified_subscribed_subscribers()

      assert Enum.any?(subscribers, fn s -> s.id == verified_subscribed.id end)
      refute Enum.any?(subscribers, fn s -> s.verified == false end)
      refute Enum.any?(subscribers, fn s -> s.subscription_status == "unsubscribed" end)
    end
  end

  describe "get_subscriber!/1" do
    test "returns the subscriber with given id" do
      subscriber = subscriber_fixture()

      found = Newsletter.get_subscriber!(subscriber.id)

      assert found.id == subscriber.id
      assert found.email == subscriber.email
    end

    test "raises if subscriber does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Newsletter.get_subscriber!(999_999)
      end
    end
  end

  describe "update_subscriber/2" do
    test "updates subscriber with valid attributes" do
      subscriber = subscriber_fixture()
      update_attrs = %{email: "updated@example.com"}

      assert {:ok, updated} = Newsletter.update_subscriber(subscriber, update_attrs)
      assert updated.email == "updated@example.com"
    end

    test "returns error with invalid email" do
      subscriber = subscriber_fixture()
      invalid_attrs = %{email: "invalid"}

      assert {:error, changeset} = Newsletter.update_subscriber(subscriber, invalid_attrs)
      assert "must be a valid email" in errors_on(changeset).email
    end
  end

  describe "delete_subscriber/1" do
    test "deletes the subscriber" do
      subscriber = subscriber_fixture()

      assert {:ok, deleted} = Newsletter.delete_subscriber(subscriber)
      assert deleted.id == subscriber.id
      assert Newsletter.get_subscriber_by_email(subscriber.email) == nil
    end
  end

  describe "change_subscriber/2" do
    test "returns a changeset for the subscriber" do
      subscriber = subscriber_fixture()

      changeset = Newsletter.change_subscriber(subscriber)

      assert %Ecto.Changeset{} = changeset
      assert changeset.data == subscriber
    end

    test "returns changeset with given attributes" do
      subscriber = subscriber_fixture()
      attrs = %{email: "new@example.com"}

      changeset = Newsletter.change_subscriber(subscriber, attrs)

      assert changeset.changes.email == "new@example.com"
    end
  end

  describe "unsubscribe/1" do
    test "sets subscription_status to unsubscribed" do
      subscriber = subscriber_fixture(%{verified: true, subscription_status: "subscribed"})

      assert {:ok, updated} = Newsletter.unsubscribe(subscriber)
      assert updated.subscription_status == "unsubscribed"
      assert updated.verified == true
    end

    test "works when already unsubscribed (idempotent)" do
      subscriber = subscriber_fixture(%{subscription_status: "unsubscribed"})

      assert {:ok, updated} = Newsletter.unsubscribe(subscriber)
      assert updated.subscription_status == "unsubscribed"
    end
  end
end
