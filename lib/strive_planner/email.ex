defmodule StrivePlanner.Email do
  @moduledoc """
  Email templates and sending functions using Resend API.
  """

  @doc """
  Sends an admin magic link email.
  """
  def send_admin_magic_link(user, token) do
    api_key = Application.get_env(:strive_planner, :resend)[:api_key]

    if is_nil(api_key) or api_key == "" do
      require Logger
      Logger.error("RESEND_API_KEY is not configured")
      {:error, :email_not_configured}
    else
      magic_link_url = "#{base_url()}/admin/verify/#{token}"

      body = %{
        from: "Strive Planner <noreply@striveplanner.org>",
        to: [user.email],
        subject: "Admin Login - Strive Planner",
        html: """
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 40px 0;">
              <tr>
                <td align="center">
                  <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <tr>
                      <td style="padding: 40px;">
                        <h1 style="margin: 0 0 24px 0; font-size: 28px; font-weight: 700; color: #111827;">
                          Admin Login
                        </h1>
                        <p style="margin: 0 0 24px 0; font-size: 16px; line-height: 1.5; color: #374151;">
                          Click the button below to sign in to the Strive Planner admin portal. This link will expire in 15 minutes.
                        </p>
                        <table width="100%" cellpadding="0" cellspacing="0">
                          <tr>
                            <td align="center" style="padding: 16px 0;">
                              <a href="#{magic_link_url}"
                                 style="display: inline-block; padding: 12px 32px; background-color: #2563eb; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px;">
                                Sign In to Admin
                              </a>
                            </td>
                          </tr>
                        </table>
                        <p style="margin: 24px 0 0 0; font-size: 14px; line-height: 1.5; color: #6b7280;">
                          If you didn't request this email, you can safely ignore it.
                        </p>
                        <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 32px 0;">
                        <p style="margin: 0; font-size: 12px; color: #9ca3af;">
                          Strive Planner<br>
                          <a href="#{base_url()}" style="color: #2563eb; text-decoration: none;">striveplanner.org</a>
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
        """
      }

      case Req.post("https://api.resend.com/emails",
             json: body,
             headers: [{"Authorization", "Bearer #{api_key}"}]
           ) do
        {:ok, %{status: 200}} ->
          require Logger
          Logger.info("Admin magic link sent successfully to #{user.email}")
          {:ok, :sent}

        {:ok, response} ->
          require Logger

          Logger.error(
            "Resend API error: status=#{response.status}, body=#{inspect(response.body)}"
          )

          {:error, :email_send_failed}

        {:error, reason} ->
          require Logger
          Logger.error("Failed to send admin magic link: #{inspect(reason)}")
          {:error, :email_send_failed}
      end
    end
  end

  @doc """
  Sends a blog post to all verified newsletter subscribers.
  """
  def send_blog_post_to_subscribers(blog_post, subscribers) do
    api_key = Application.get_env(:strive_planner, :resend)[:api_key]

    if is_nil(api_key) or api_key == "" do
      require Logger
      Logger.error("RESEND_API_KEY is not configured")
      {:error, :email_not_configured}
    else
      # Send individual emails to include unique unsubscribe links
      results =
        Enum.map(subscribers, fn subscriber ->
          send_individual_blog_post_email(blog_post, subscriber, api_key)
        end)

      # Check if all succeeded
      if Enum.all?(results, &(&1 == :ok)) do
        {:ok, :sent}
      else
        {:error, :some_failed}
      end
    end
  end

  defp send_individual_blog_post_email(blog_post, subscriber, api_key) do
    html_content = StrivePlanner.Blog.render_markdown(blog_post.content)
    blog_url = "#{base_url()}/blog/#{blog_post.slug}"

    unsubscribe_token =
      Phoenix.Token.sign(StrivePlannerWeb.Endpoint, "unsubscribe", subscriber.id)

    unsubscribe_url = "#{base_url()}/unsubscribe?token=#{unsubscribe_token}"

    body = %{
      from: "Strive Planner <noreply@striveplanner.org>",
      to: [subscriber.email],
      reply_to: "blog@striveplanner.org",
      subject: blog_post.title,
      html: """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 40px 0;">
            <tr>
              <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <tr>
                    <td style="padding: 40px;">
                      <h1 style="margin: 0 0 16px 0; font-size: 32px; font-weight: 700; color: #111827; line-height: 1.2;">
                        #{Phoenix.HTML.html_escape(blog_post.title) |> Phoenix.HTML.safe_to_string()}
                      </h1>
                      #{if blog_post.excerpt do
        "<p style=\"margin: 0 0 24px 0; font-size: 16px; line-height: 1.5; color: #6b7280;\">#{Phoenix.HTML.html_escape(blog_post.excerpt) |> Phoenix.HTML.safe_to_string()}</p>"
      else
        ""
      end}
                      <div style="margin: 24px 0; padding: 24px 0; border-top: 1px solid #e5e7eb; border-bottom: 1px solid #e5e7eb;">
                        <div style="font-size: 16px; line-height: 1.6; color: #374151;">
                          #{html_content}
                        </div>
                      </div>
                      <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                          <td align="center" style="padding: 16px 0;">
                            <a href="#{blog_url}"
                               style="display: inline-block; padding: 12px 32px; background-color: #2563eb; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px;">
                              Read on Website
                            </a>
                          </td>
                        </tr>
                      </table>
                      <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 32px 0;">
                      <p style="margin: 0; font-size: 12px; color: #9ca3af;">
                        You're receiving this email because you subscribed to the Strive Planner newsletter.<br>
                        <a href="#{base_url()}/blog" style="color: #2563eb; text-decoration: none;">View all posts</a> |
                        <a href="#{base_url()}" style="color: #2563eb; text-decoration: none;">striveplanner.org</a> |
                        <a href="#{unsubscribe_url}" style="color: #9ca3af; text-decoration: underline;">Unsubscribe</a>
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>
      """
    }

    case Req.post("https://api.resend.com/emails",
           json: body,
           headers: [{"Authorization", "Bearer #{api_key}"}]
         ) do
      {:ok, %{status: 200}} ->
        require Logger
        Logger.info("Blog post sent to #{subscriber.email}")
        :ok

      {:ok, response} ->
        require Logger

        Logger.error(
          "Resend API error for #{subscriber.email}: status=#{response.status}, body=#{inspect(response.body)}"
        )

        {:error, :email_send_failed}

      {:error, reason} ->
        require Logger
        Logger.error("Failed to send blog post email to #{subscriber.email}: #{inspect(reason)}")
        {:error, :email_send_failed}
    end
  end

  @doc """
  Sends a verification email to a subscriber.
  """
  def send_verification_email(subscriber, token) do
    api_key = Application.get_env(:strive_planner, :resend)[:api_key]

    if is_nil(api_key) or api_key == "" do
      require Logger
      Logger.error("RESEND_API_KEY is not configured")
      {:error, :email_not_configured}
    else
      verification_url = "#{base_url()}/newsletter/verify/#{token}"

      body = %{
        from: "Strive Planner <noreply@striveplanner.org>",
        to: [subscriber.email],
        reply_to: "blog@striveplanner.org",
        subject: "Welcome to the Strive Planner blog!",
        html: """
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 600px; margin: 0 auto; padding: 48px 32px;">
          <div style="text-align: center; margin-bottom: 48px;">
            <h1 style="font-size: 28px; font-weight: 400; color: #1f2937; margin: 0 0 16px 0; line-height: 1.2;">
              Welcome to the blog!
            </h1>
            <p style="font-size: 16px; color: #4b5563; margin: 0; line-height: 1.6;">
              Insights and tips on productivity, goal setting, and living with intention.
            </p>
          </div>

          <div style="background-color: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 32px; margin-bottom: 32px;">
            <p style="font-size: 14px; color: #374151; margin: 0 0 24px 0; line-height: 1.6;">
              Please verify your email address to complete your subscription.
            </p>

            <div style="text-align: center; margin: 32px 0;">
              <a href="#{verification_url}"
                 style="display: inline-block;
                        background: linear-gradient(to right, #40e0d0, #3bd89d);
                        color: #0a0a0a;
                        padding: 12px 32px;
                        text-decoration: none;
                        border-radius: 6px;
                        font-weight: 500;
                        font-size: 14px;">
                Verify Email Address
              </a>
            </div>

            <p style="font-size: 13px; color: #6b7280; margin: 24px 0 0 0; line-height: 1.5;">
              This link will expire in 24 hours. If you didn't subscribe to this newsletter, you can safely ignore this email.
            </p>
          </div>

          <div style="text-align: center; padding-top: 32px; border-top: 1px solid #e5e7eb;">
            <p style="font-size: 12px; color: #9ca3af; margin: 0;">
              Weiss Solutions LLC
            </p>
            <p style="font-size: 12px; margin: 8px 0 0 0;">
              <a href="#{base_url()}" style="color: #40e0d0; text-decoration: none;">striveplanner.org</a>
            </p>
          </div>
        </div>
        """
      }

      case Req.post("https://api.resend.com/emails",
             json: body,
             headers: [{"Authorization", "Bearer #{api_key}"}]
           ) do
        {:ok, %{status: 200}} ->
          require Logger
          Logger.info("Verification email sent successfully to #{subscriber.email}")
          :ok

        {:ok, response} ->
          require Logger

          Logger.error(
            "Resend API error: status=#{response.status}, body=#{inspect(response.body)}"
          )

          {:error, :email_send_failed}

        {:error, reason} ->
          require Logger
          Logger.error("Failed to send verification email: #{inspect(reason)}")
          {:error, :email_send_failed}
      end
    end
  end

  defp base_url do
    Application.get_env(:strive_planner, StrivePlannerWeb.Endpoint)[:url][:host]
    |> case do
      "localhost" -> "http://localhost:4000"
      host -> "https://#{host}"
    end
  end
end
