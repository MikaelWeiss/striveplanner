defmodule StrivePlannerWeb.API.NewsletterController do
  use StrivePlannerWeb, :controller

  alias StrivePlanner.Newsletter
  alias StrivePlanner.Email
  alias StrivePlanner.RateLimiter

  def subscribe(conn, %{"email" => email}) do
    with :ok <- check_rate_limit(conn),
         :ok <- validate_email(email),
         {:ok, result} <- handle_subscription(email) do
      json(conn, %{message: result})
    else
      {:error, :rate_limited} ->
        conn
        |> put_status(429)
        |> json(%{error: "Too many requests. Please try again later."})

      {:error, :invalid_email} ->
        conn
        |> put_status(400)
        |> json(%{error: "Please provide a valid email address."})

      {:error, :already_subscribed} ->
        json(conn, %{message: "You are already subscribed to the newsletter."})

      {:error, _reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "An unexpected error occurred. Please try again."})
    end
  end

  def subscribe(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Email is required."})
  end

  defp check_rate_limit(conn) do
    client_ip = get_client_ip(conn)
    rate_limit_key = "newsletter_subscribe:#{client_ip}"

    # Rate limit: 5 requests per minute per IP
    RateLimiter.check_rate(rate_limit_key, 5, 60_000)
  end

  defp get_client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [ip | _] -> ip
      [] -> conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    end
  end

  defp validate_email(email) when is_binary(email) do
    if Regex.match?(~r/^[^\s]+@[^\s]+\.[^\s]+$/, email) do
      :ok
    else
      {:error, :invalid_email}
    end
  end

  defp validate_email(_), do: {:error, :invalid_email}

  defp handle_subscription(email) do
    case Newsletter.get_subscriber_by_email(email) do
      nil ->
        create_and_send_verification(email)

      %{verified: true} ->
        {:error, :already_subscribed}

      subscriber ->
        # Resend verification email - generate new token
        case Newsletter.generate_verification_token(subscriber) do
          {:ok, subscriber, token} ->
            Email.send_verification_email(subscriber, token)
            {:ok, "A verification email has been sent to your inbox."}

          error ->
            error
        end
    end
  end

  defp create_and_send_verification(email) do
    with {:ok, subscriber} <- Newsletter.create_subscriber(%{email: email}),
         {:ok, subscriber, token} <- Newsletter.generate_verification_token(subscriber),
         :ok <- Email.send_verification_email(subscriber, token) do
      {:ok, "Please check your email to verify your subscription."}
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
