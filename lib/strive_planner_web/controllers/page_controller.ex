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
end
