defmodule StrivePlannerWeb.PageController do
  use StrivePlannerWeb, :controller
  import Phoenix.Component
  alias StrivePlanner.Email

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def contact(conn, params) do
    case conn.method do
      "GET" ->
        # For GET requests, just render the form
        form = to_form(%{"name" => "", "email" => "", "subject" => "", "message" => ""})
        render(conn, :contact, form: form)

      "POST" ->
        # For POST requests, verify recaptcha
        case verify_recaptcha(params["g-recaptcha-response"]) do
          {:ok, _score} ->
            # Process the contact form submission
            submit_contact(conn, params)

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Could not verify that you are human. Please try again.")
            |> redirect(to: ~p"/contact")
        end
    end
  end

  def submit_contact(
        conn,
        %{"name" => name, "email" => email, "subject" => subject, "message" => message} = _params
      ) do
    case Email.contact_form_email(name, email, subject, message) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thank you for your message! We'll get back to you soon.")
        |> redirect(to: ~p"/contact")

      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry, there was an error sending your message. Please try again.")
        |> redirect(to: ~p"/contact")
    end
  end

  def support(conn, _params) do
    render(conn, :support)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def terms_of_service(conn, _params) do
    render(conn, :terms_of_service)
  end

  def coming_soon(conn, _params) do
    form = to_form(%{"email" => ""})
    render(conn, :coming_soon, form: form)
  end

  defp verify_recaptcha(nil), do: {:error, "No reCAPTCHA token provided"}
  defp verify_recaptcha(token) do
    url = "https://www.google.com/recaptcha/api/siteverify"
    secret_key = Application.get_env(:strive_planner, :recaptcha)[:secret_key]

    case HTTPoison.post(url, {:form, [
      secret: secret_key,
      response: token
    ]}) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"success" => true, "score" => score}} when score > 0.5 ->
            {:ok, score}
          _ ->
            {:error, "reCAPTCHA verification failed"}
        end
      _ ->
        {:error, "Could not verify reCAPTCHA"}
    end
  end
end
