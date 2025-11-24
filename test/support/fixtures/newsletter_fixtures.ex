defmodule StrivePlanner.NewsletterFixtures do
  @moduledoc """
  This module defines test fixtures for Newsletter context.

  Fixtures create reusable test data for newsletter subscription testing.
  All fixtures use unique emails to prevent conflicts in async tests.

  ## Fixture Pattern

  Fixtures follow Phoenix conventions:
  - Each fixture inserts data into the database
  - Default attributes can be overridden via attrs parameter
  - Uses `System.unique_integer/1` for unique values in async tests

  ## Usage

      import StrivePlanner.NewsletterFixtures

      test "example" do
        subscriber = subscriber_fixture(%{email: "test@example.com"})
        # Use subscriber in test...
      end
  """

  alias StrivePlanner.Newsletter

  @doc """
  Creates an unverified subscriber with a unique email.

  ## Examples

      iex> subscriber = subscriber_fixture()
      iex> subscriber.verified
      false

      iex> subscriber = subscriber_fixture(%{email: "custom@example.com"})
      iex> subscriber.email
      "custom@example.com"

  """
  def subscriber_fixture(attrs \\ %{}) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(%{
        email: "subscriber-#{System.unique_integer([:positive])}@example.com",
        verified: false,
        subscription_status: "subscribed"
      })
      |> Newsletter.create_subscriber()

    subscriber
  end

  @doc """
  Creates a verified subscriber.

  ## Examples

      iex> subscriber = verified_subscriber_fixture()
      iex> subscriber.verified
      true

  """
  def verified_subscriber_fixture(attrs \\ %{}) do
    attrs
    |> Map.put(:verified, true)
    |> subscriber_fixture()
  end

  @doc """
  Creates a subscriber with a valid verification token.

  ## Examples

      iex> subscriber = subscriber_with_token_fixture()
      iex> subscriber.verification_token
      "test-token-..."

  """
  def subscriber_with_token_fixture(attrs \\ %{}) do
    subscriber = subscriber_fixture(attrs)

    {:ok, updated_subscriber, _token} = Newsletter.generate_verification_token(subscriber)

    updated_subscriber
  end

  @doc """
  Creates an unsubscribed subscriber.

  ## Examples

      iex> subscriber = unsubscribed_subscriber_fixture()
      iex> subscriber.subscription_status
      "unsubscribed"

  """
  def unsubscribed_subscriber_fixture(attrs \\ %{}) do
    attrs
    |> Map.put(:subscription_status, "unsubscribed")
    |> subscriber_fixture()
  end
end
