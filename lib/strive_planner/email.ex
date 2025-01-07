defmodule StrivePlanner.Email do
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
