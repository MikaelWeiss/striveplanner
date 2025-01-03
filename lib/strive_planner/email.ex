defmodule StrivePlanner.Email do
  def notify_about_ios_app(email) do
    Resend.Emails.send(%{
      from: "notifications@striveplanner.org",
      to: "stay-updated@striveplanner.org",
      subject: "New iOS App Interest: #{email}",
      text: "A new user has expressed interest in the iOS app.\n\nEmail: #{email}"
    })
  end

  def contact_form_email(name, email, subject, message) do
    Resend.Emails.send(%{
      from: "notifications@striveplanner.org",
      to: "contact@striveplanner.org",
      subject: "Contact Form: #{subject}",
      text: """
      Name: #{name}
      Email: #{email}
      Subject: #{subject}

      Message:
      #{message}
      """
    })
  end
end
