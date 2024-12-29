defmodule StrivePlannerWeb.PageController do
  use StrivePlannerWeb, :controller
  import Phoenix.Component

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
        %{"name" => name, "email" => email, "subject" => subject, "message" => message} = params
      ) do
    # Here you would typically send an email or store the contact form submission
    # For now, we'll just redirect with a flash message
    conn
    |> put_flash(:info, "Thank you for your message! We'll get back to you soon.")
    |> redirect(to: ~p"/contact")
  end
end
