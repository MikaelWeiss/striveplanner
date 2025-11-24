defmodule StrivePlannerWeb.PageController do
  use StrivePlannerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def support(conn, _params) do
    render(conn, :support)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def terms_of_service(conn, _params) do
    render(conn, :terms_of_service)
  end

  def contact(conn, _params) do
    recaptcha_site_key = Application.get_env(:strive_planner, :recaptcha)[:site_key]
    render(conn, :contact, recaptcha_site_key: recaptcha_site_key, flash_message: nil)
  end

  def contact_submit(conn, params) do
    recaptcha_site_key = Application.get_env(:strive_planner, :recaptcha)[:site_key]

    with {:ok, _} <- verify_recaptcha(params["g-recaptcha-response"]),
         {:ok, _} <- send_contact_email(params) do
      conn
      |> put_flash(:info, "Thank you for your message! We'll get back to you soon.")
      |> redirect(to: "/contact")
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render(:contact, recaptcha_site_key: recaptcha_site_key, flash_message: reason)
    end
  end

  defp verify_recaptcha(nil), do: {:error, "reCAPTCHA verification failed"}

  defp verify_recaptcha(token) do
    secret_key = Application.get_env(:strive_planner, :recaptcha)[:secret_key]

    case Req.post("https://www.google.com/recaptcha/api/siteverify",
           form: [secret: secret_key, response: token]
         ) do
      {:ok, %{body: %{"success" => true, "score" => score}}} when score > 0.5 ->
        {:ok, :verified}

      {:ok, %{body: %{"success" => false}}} ->
        {:error, "reCAPTCHA verification failed"}

      _ ->
        {:error, "reCAPTCHA verification error"}
    end
  end

  defp send_contact_email(%{
         "name" => name,
         "email" => email,
         "subject" => subject,
         "message" => message
       }) do
    api_key = Application.get_env(:strive_planner, :resend)[:api_key]

    body = %{
      from: "Strive Planner <noreply@striveplanner.org>",
      to: ["support@striveplanner.org"],
      reply_to: email,
      subject: "Contact Form: #{subject}",
      html: """
      <h2>New Contact Form Submission</h2>
      <p><strong>Name:</strong> #{name}</p>
      <p><strong>Email:</strong> #{email}</p>
      <p><strong>Subject:</strong> #{subject}</p>
      <p><strong>Message:</strong></p>
      <p>#{message}</p>
      """
    }

    case Req.post("https://api.resend.com/emails",
           json: body,
           headers: [{"Authorization", "Bearer #{api_key}"}]
         ) do
      {:ok, %{status: 200}} ->
        {:ok, :sent}

      _ ->
        {:error, "Failed to send email. Please try again."}
    end
  end

  defp send_contact_email(_), do: {:error, "Missing required fields"}

  def verify_newsletter(conn, %{"token" => token}) do
    case StrivePlanner.Newsletter.verify_subscriber(token) do
      {:ok, _subscriber} ->
        conn
        |> redirect(to: "/newsletter/welcome")

      {:error, :invalid_or_expired_token} ->
        conn
        |> put_flash(
          :error,
          "This verification link is invalid or has expired. Please subscribe again."
        )
        |> redirect(to: "/")
    end
  end

  def newsletter_welcome(conn, _params) do
    posts = StrivePlanner.Blog.list_posts() |> Enum.take(3)
    render(conn, :newsletter_welcome, posts: posts)
  end

  def blog_index(conn, _params) do
    posts = StrivePlanner.Blog.list_posts()
    render(conn, :blog_index, posts: posts)
  end

  def blog_post(conn, %{"slug" => slug}) do
    case StrivePlanner.Blog.get_post(slug) do
      {:ok, post} ->
        # Increment view count
        StrivePlanner.Blog.increment_view_count(post)

        # Render markdown to HTML
        html_content = StrivePlanner.Blog.render_markdown(post.content)

        render(conn, :blog_post, post: post, html_content: html_content)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> put_view(StrivePlannerWeb.ErrorHTML)
        |> render(:"404")
    end
  end
end
