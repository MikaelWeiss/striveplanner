defmodule StrivePlanner.Email do
  import Swoosh.Email

  def contact_form_email(name, email, subject, message) do
    new()
    |> to({"Contact", "contact@weisssolutions.org"})
    |> from({name, email})
    |> subject("Contact Form Submission: #{subject}")
    |> html_body("""
    <h2>New Contact Form Submission</h2>
    <p><strong>From:</strong> #{name} (#{email})</p>
    <p><strong>Subject:</strong> #{subject}</p>
    <p><strong>Message:</strong></p>
    <p>#{message}</p>
    """)
  end
end
