defmodule StrivePlannerWeb.Newsletter.UnsubscribeController do
  use StrivePlannerWeb, :controller

  alias StrivePlanner.Newsletter

  @doc """
  Handles unsubscribe requests with signed tokens.

  Token format: Phoenix.Token.sign(conn, "unsubscribe", subscriber_id)
  """
  def unsubscribe(conn, %{"token" => token}) do
    case Phoenix.Token.verify(conn, "unsubscribe", token, max_age: :infinity) do
      {:ok, subscriber_id} ->
        case Newsletter.get_subscriber(subscriber_id) do
          nil ->
            render_error(conn, "Subscriber not found")

          subscriber ->
            case Newsletter.unsubscribe(subscriber) do
              {:ok, _updated} ->
                render(conn, :unsubscribe, success: true)

              {:error, _changeset} ->
                render_error(conn, "Unable to unsubscribe")
            end
        end

      {:error, _reason} ->
        render_error(conn, "Invalid or expired token")
    end
  end

  def unsubscribe(conn, _params) do
    render_error(conn, "Missing unsubscribe token")
  end

  defp render_error(conn, message) do
    conn
    |> put_status(:bad_request)
    |> render(:unsubscribe, success: false, error: message)
  end
end
