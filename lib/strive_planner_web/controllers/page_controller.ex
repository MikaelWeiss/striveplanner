defmodule StrivePlannerWeb.PageController do
  use StrivePlannerWeb, :controller
  import Phoenix.Component
  alias StrivePlanner.Email

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def contact(conn, _params) do
    form = to_form(%{"name" => "", "email" => "", "subject" => "", "message" => ""})
    render(conn, :contact, form: form)
  end

  def submit_contact(
        conn,
        %{"name" => name, "email" => email, "subject" => subject, "message" => message, "g-recaptcha-response" => recaptcha_token} = _params
      ) do
    case verify_recaptcha(recaptcha_token) do
      {:ok, score} when score >= 0.5 ->
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

      {:ok, _low_score} ->
        conn
        |> put_flash(:error, "Security verification failed. Please try again.")
        |> redirect(to: ~p"/contact")

      {:error, _} ->
        conn
        |> put_flash(:error, "Security verification failed. Please try again.")
        |> redirect(to: ~p"/contact")
    end
  end

  defp verify_recaptcha(token) do
    case Recaptcha.verify(token) do
      {:ok, %Recaptcha.Response{}} ->
        {:ok, 1.0}
      {:error, _} ->
        {:error, :verification_failed}
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

  def magic_link_failed(conn, _params) do
    render(conn, :magic_link_failed)
  end
end
