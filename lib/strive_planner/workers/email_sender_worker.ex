defmodule StrivePlanner.Workers.EmailSenderWorker do
  @moduledoc """
  Oban worker that sends a blog post email to a single subscriber.

  This worker is used to rate-limit email sends to stay under Resend's
  2 requests/second API limit. Each job sends one email to one subscriber.

  ## Job Arguments

  - `blog_post_id` - The ID of the blog post to send
  - `subscriber_id` - The ID of the subscriber to send to
  """
  use Oban.Worker, queue: :emails, max_attempts: 3

  alias StrivePlanner.Repo
  alias StrivePlanner.Blog.BlogPost
  alias StrivePlanner.Newsletter.Subscriber

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"blog_post_id" => blog_post_id, "subscriber_id" => subscriber_id}
      }) do
    # Load the blog post and subscriber
    blog_post = Repo.get(BlogPost, blog_post_id)
    subscriber = Repo.get(Subscriber, subscriber_id)

    case {blog_post, subscriber} do
      {nil, _} ->
        require Logger
        Logger.error("EmailSenderWorker: Blog post #{blog_post_id} not found")
        {:error, :blog_post_not_found}

      {_, nil} ->
        require Logger
        Logger.error("EmailSenderWorker: Subscriber #{subscriber_id} not found")
        {:error, :subscriber_not_found}

      {post, sub} ->
        # Send the email using the existing function
        api_key = Application.get_env(:strive_planner, :resend)[:api_key]

        case send_individual_blog_post_email(post, sub, api_key) do
          :ok ->
            :ok

          {:error, reason} ->
            require Logger
            Logger.error("EmailSenderWorker: Failed to send email: #{inspect(reason)}")
            {:error, reason}
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

  defp base_url do
    Application.get_env(:strive_planner, StrivePlannerWeb.Endpoint)[:url][:host]
    |> case do
      "localhost" -> "http://localhost:4000"
      host -> "https://#{host}"
    end
  end
end
