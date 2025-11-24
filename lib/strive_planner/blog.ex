defmodule StrivePlanner.Blog do
  @moduledoc """
  The Blog context for managing blog posts.
  """

  import Ecto.Query, warn: false
  alias StrivePlanner.Repo
  alias StrivePlanner.Blog.BlogPost
  alias StrivePlanner.Newsletter.EmailDelivery

  @doc """
  Returns all published blog posts sorted by publication date (newest first).
  """
  def list_posts do
    BlogPost
    |> where([p], p.status == "published")
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Returns all blog posts (for admin) with stats, sorted by published_at (newest first).
  """
  def list_all_posts do
    BlogPost
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Gets a single published blog post by slug for public viewing.
  """
  def get_post(slug) do
    case Repo.get_by(BlogPost, slug: slug, status: "published") do
      nil -> {:error, :not_found}
      post -> {:ok, post}
    end
  end

  @doc """
  Gets a single blog post by ID (for admin).
  """
  def get_post!(id) do
    Repo.get!(BlogPost, id)
  end

  @doc """
  Creates a blog post.
  """
  def create_post(attrs \\ %{}) do
    %BlogPost{}
    |> BlogPost.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blog post.
  """
  def update_post(%BlogPost{} = post, attrs) do
    post
    |> BlogPost.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a blog post.
  """
  def delete_post(%BlogPost{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blog post changes.
  """
  def change_post(%BlogPost{} = post, attrs \\ %{}) do
    BlogPost.changeset(post, attrs)
  end

  @doc """
  Increments the view count for a blog post.
  """
  def increment_view_count(%BlogPost{} = post) do
    post
    |> Ecto.Changeset.change(view_count: post.view_count + 1)
    |> Repo.update()
  end

  @doc """
  Renders markdown content to HTML.
  """
  def render_markdown(content) when is_binary(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> html
      _ -> content
    end
  end

  def render_markdown(_), do: ""

  @doc """
  Publishes a draft blog post.

  Sets status to "published" and sets published_at to current time if not already set.
  Cancels any scheduled email to prevent duplicate sends.

  ## Examples

      iex> publish_post(draft_post)
      {:ok, %BlogPost{status: "published", published_at: ~U[...]}}

  """
  def publish_post(%BlogPost{} = post) do
    # Cancel any scheduled email first to prevent duplicate sends
    if post.scheduled_email_for do
      cancel_email_job(post)
    end

    published_at = post.published_at || DateTime.utc_now() |> DateTime.truncate(:second)

    post
    |> Ecto.Changeset.change(%{
      status: "published",
      published_at: published_at,
      scheduled_email_for: nil
    })
    |> Repo.update()
  end

  @doc """
  Unpublishes a published blog post.

  Sets status to "draft", preserves published_at (history), and cancels any scheduled email.

  ## Examples

      iex> unpublish_post(published_post)
      {:ok, %BlogPost{status: "draft", scheduled_email_for: nil}}

  """
  def unpublish_post(%BlogPost{} = post) do
    post
    |> Ecto.Changeset.change(%{
      status: "draft",
      scheduled_email_for: nil
    })
    |> Repo.update()
  end

  @doc """
  Schedules an email to be sent at a specified future time.

  Sets scheduled_email_for and enqueues an Oban job to send the email at that time.
  Uses a transaction to ensure atomicity between post update and job creation.

  ## Examples

      iex> future_time = DateTime.utc_now() |> DateTime.add(3600, :second)
      iex> schedule_email(post, future_time)
      {:ok, %BlogPost{scheduled_email_for: ~U[...]}}

  """
  def schedule_email(%BlogPost{} = post, scheduled_time) do
    # Cancel any existing scheduled email first
    if post.scheduled_email_for do
      cancel_email_job(post)
    end

    # Validate the scheduled time is in the future
    changeset =
      post
      |> BlogPost.changeset(%{scheduled_email_for: scheduled_time})

    if changeset.valid? do
      # Use a transaction to ensure atomicity
      Ecto.Multi.new()
      |> Ecto.Multi.update(:post, changeset)
      |> Ecto.Multi.run(:job, fn _repo, %{post: updated_post} ->
        case enqueue_email_job(updated_post) do
          {:ok, job} -> {:ok, job}
          error -> error
        end
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{post: updated_post}} -> {:ok, updated_post}
        {:error, :post, changeset, _} -> {:error, changeset}
        {:error, :job, reason, _} -> {:error, reason}
      end
    else
      {:error, changeset}
    end
  end

  @doc """
  Cancels a scheduled email for a blog post.

  Clears scheduled_email_for and cancels the Oban job.

  ## Examples

      iex> cancel_scheduled_email(post)
      {:ok, %BlogPost{scheduled_email_for: nil}}

  """
  def cancel_scheduled_email(%BlogPost{} = post) do
    # Cancel the Oban job if it exists
    if post.scheduled_email_for do
      cancel_email_job(post)
    end

    # Clear the scheduled_email_for field
    post
    |> Ecto.Changeset.change(%{scheduled_email_for: nil})
    |> Repo.update()
  end

  @doc """
  Processes all scheduled emails that are due to be sent.

  Queries for posts with scheduled_email_for <= now and sent_to_subscribers = false,
  then sends emails to verified subscribers for each post.

  Returns {:ok, count} where count is the number of emails sent.
  """
  def process_scheduled_emails do
    now = DateTime.utc_now()

    posts =
      BlogPost
      |> where([p], p.scheduled_email_for <= ^now)
      |> where([p], p.sent_to_subscribers == false)
      |> where([p], not is_nil(p.scheduled_email_for))
      |> Repo.all()

    sent_count =
      Enum.reduce(posts, 0, fn post, acc ->
        case send_to_subscribers(post) do
          {:ok, count} -> acc + count
          _ -> acc
        end
      end)

    {:ok, sent_count}
  end

  @doc """
  Queues blog post emails to all verified newsletter subscribers.
  Returns {:ok, count} with the number of emails queued, or {:error, reason}.

  Emails are sent via background jobs with rate limiting to comply with
  Resend's 2 requests/second API limit.
  """
  def send_to_subscribers(%BlogPost{} = post) do
    # Get all verified and subscribed subscribers
    subscribers =
      StrivePlanner.Repo.all(
        from s in StrivePlanner.Newsletter.Subscriber,
          where: s.verified == true and s.subscription_status == "subscribed"
      )

    if Enum.empty?(subscribers) do
      {:error, :no_subscribers}
    else
      sent_at = DateTime.utc_now() |> DateTime.truncate(:second)
      naive_now = DateTime.to_naive(sent_at)

      # Queue individual email jobs for rate limiting
      Enum.each(subscribers, fn subscriber ->
        %{blog_post_id: post.id, subscriber_id: subscriber.id}
        |> StrivePlanner.Workers.EmailSenderWorker.new()
        |> Oban.insert()
      end)

      # Create email delivery records for tracking
      email_deliveries =
        Enum.map(subscribers, fn subscriber ->
          %{
            subscriber_id: subscriber.id,
            blog_post_id: post.id,
            sent_at: sent_at,
            inserted_at: naive_now,
            updated_at: naive_now
          }
        end)

      Repo.insert_all(EmailDelivery, email_deliveries)

      # Update the post to mark it as sent
      post
      |> Ecto.Changeset.change(%{
        email_sent_at: sent_at,
        email_recipient_count: length(subscribers),
        sent_to_subscribers: true
      })
      |> Repo.update()

      {:ok, length(subscribers)}
    end
  end

  # Private helper functions

  defp enqueue_email_job(%BlogPost{} = post) do
    %{post_id: post.id}
    |> StrivePlanner.Workers.EmailScheduler.new(scheduled_at: post.scheduled_email_for)
    |> Oban.insert()
  end

  defp cancel_email_job(%BlogPost{} = post) do
    import Ecto.Query

    Oban.Job
    |> where([j], j.worker == "StrivePlanner.Workers.EmailScheduler")
    |> where([j], fragment("?->>'post_id' = ?", j.args, ^to_string(post.id)))
    |> where([j], j.state in ["available", "scheduled", "retryable"])
    |> Repo.all()
    |> Enum.each(&Oban.cancel_job/1)
  end
end
