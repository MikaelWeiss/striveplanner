defmodule StrivePlanner.Email do
  def contact_form_email(name, email, subject, message) do
    Resend.Emails.send(%{
      from: "Strive Planner <support@striveplanner.org>",
      to: "campingmikael@icloud.com",
      subject: "Contact Form Submission: #{subject}",
      html: """
      <h2>New Contact Form Submission</h2>
      <p><strong>From:</strong> #{name} (#{email})</p>
      <p><strong>Subject:</strong> #{subject}</p>
      <p><strong>Message:</strong></p>
      <p>#{message}</p>
      """
    })
  end
end
