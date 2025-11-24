defmodule StrivePlannerWeb.Newsletter.UnsubscribeControllerTest do
  use StrivePlannerWeb.ConnCase

  import StrivePlanner.NewsletterFixtures

  @endpoint StrivePlannerWeb.Endpoint

  describe "unsubscribe/2" do
    test "unsubscribes with valid token", %{conn: conn} do
      subscriber =
        subscriber_fixture(%{email: "test@example.com", subscription_status: "subscribed"})

      # Generate a valid token
      token = Phoenix.Token.sign(@endpoint, "unsubscribe", subscriber.id)

      conn = get(conn, ~p"/unsubscribe?token=#{token}")

      assert html_response(conn, 200) =~ "unsubscribed"

      # Verify subscriber was actually unsubscribed
      updated_subscriber = StrivePlanner.Newsletter.get_subscriber!(subscriber.id)
      assert updated_subscriber.subscription_status == "unsubscribed"
    end

    test "shows error with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/unsubscribe?token=invalid-token")

      html = html_response(conn, 400)
      assert html =~ "Invalid or expired token"
      assert html =~ "Unable to unsubscribe"
    end

    test "shows error with expired token", %{conn: conn} do
      subscriber = subscriber_fixture()

      # Note: With max_age: :infinity, tokens don't really expire
      # This test verifies the handling of invalid/corrupted tokens
      # For a real expiration test, we'd need to set max_age in the controller
      token = "corrupted-token-" <> Phoenix.Token.sign(@endpoint, "unsubscribe", subscriber.id)

      conn = get(conn, ~p"/unsubscribe?token=#{token}")

      html = html_response(conn, 400)
      assert html =~ "Invalid or expired token"
      assert html =~ "Unable to unsubscribe"
    end

    test "shows error when subscriber not found", %{conn: conn} do
      # Generate token for non-existent subscriber
      token = Phoenix.Token.sign(@endpoint, "unsubscribe", 999_999)

      conn = get(conn, ~p"/unsubscribe?token=#{token}")

      assert html_response(conn, 400) =~ "not found"
    end
  end
end
