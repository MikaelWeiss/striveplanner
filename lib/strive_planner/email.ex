defmodule StrivePlanner.Email do
  import Swoosh.Email

  def notify_about_ios_app(email) do
    new()
    |> to("stay-updated@striveplanner.org")
    |> from({"Strive Planner", "notifications@striveplanner.org"})
    |> subject("New iOS App Interest: #{email}")
    |> text_body("A new user has expressed interest in the iOS app.\n\nEmail: #{email}")
    |> StrivePlanner.Mailer.deliver()
  end

  def contact_form_email(name, email, subject, message) do
    new()
    |> to("contact@striveplanner.org")
    |> from({"Strive Contact Form", "notifications@striveplanner.org"})
    |> subject("Contact Form: #{subject}")
    |> text_body("""
    Name: #{name}
    Email: #{email}
    Subject: #{subject}

    Message:
    #{message}
    """)
    |> StrivePlanner.Mailer.deliver()
  end
end
