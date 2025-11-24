# Quickstart Guide: Blog Post Management and Mailing List

**Feature**: 001-blog-mailing
**Date**: 2025-10-24

## Purpose

This guide provides developers with a quick reference for implementing and using the blog post management and mailing list features. Use this during development and for onboarding new team members.

## Prerequisites

- Phoenix 1.8.0 installed
- PostgreSQL running
- Oban dependency added to mix.exs
- Familiarity with Phoenix Contexts and LiveView

## Setup

### 1. Add Oban Dependency

```elixir
# mix.exs
defp deps do
  [
    # ... existing deps
    {:oban, "~> 2.18"}
  ]
end
```

```bash
mix deps.get
```

### 2. Run Database Migrations

```bash
# Generate migrations
mix ecto.gen.migration add_subscription_status_to_subscribers
mix ecto.gen.migration add_scheduled_email_index_to_blog_posts

# Edit migrations (see data-model.md for migration code)

# Run migrations
mix ecto.migrate
```

### 3. Configure Oban

```elixir
# config/config.exs
config :strive_planner, Oban,
  repo: StrivePlanner.Repo,
  queues: [emails: 10],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}, # 7 days
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", StrivePlanner.Workers.EmailScheduler} # Every minute
     ]}
  ]

# lib/strive_planner/application.ex
def start(_type, _args) do
  children = [
    # ... existing children
    {Oban, Application.fetch_env!(:strive_planner, Oban)}
  ]
  # ...
end
```

---

## Quick Reference

### Admin: Create and Publish Blog Post

```elixir
# In LiveView or IEx

# Create draft
{:ok, post} = StrivePlanner.Blog.create_post(%{
  title: "10 Steps to Better Goals",
  content: "Your markdown content here...",
  status: "draft"
})

# Publish to website
{:ok, post} = StrivePlanner.Blog.publish_post(post)
```

### Admin: Schedule Email for Blog Post

```elixir
# Schedule for tomorrow at 9am
tomorrow_9am =
  DateTime.utc_now()
  |> DateTime.add(86400, :second) # +1 day
  |> DateTime.to_date()
  |> DateTime.new!(~T[09:00:00])

{:ok, post} = StrivePlanner.Blog.schedule_email(post, tomorrow_9am)
# Oban job automatically enqueued
```

### Admin: Unpublish Post (Cancels Email)

```elixir
{:ok, post} = StrivePlanner.Blog.unpublish_post(post)
# Post removed from website
# Scheduled email cancelled
# post.scheduled_email_for is now nil
```

### Admin: Manage Subscribers

```elixir
# List all subscribers
subscribers = StrivePlanner.Newsletter.list_subscribers()

# Create new subscriber
{:ok, sub} = StrivePlanner.Newsletter.create_subscriber(%{
  email: "user@example.com"
})

# Update subscriber
{:ok, sub} = StrivePlanner.Newsletter.update_subscriber(sub, %{
  verified: true
})

# Delete subscriber
{:ok, _} = StrivePlanner.Newsletter.delete_subscriber(sub)
```

### User: Unsubscribe

```http
GET /unsubscribe?token=<signed_token>
```

Token generated in email template:
```elixir
# In email template
token = Phoenix.Token.sign(@conn, "unsubscribe", subscriber.id)
unsubscribe_url = url(~p"/unsubscribe?token=#{token}")
```

---

## Common Patterns

### Pattern 1: Blog Post Lifecycle (Admin UI)

```elixir
# BlogPostLive.FormComponent
def handle_event("save", %{"blog_post" => params}, socket) do
  case socket.assigns.action do
    :new -> Blog.create_post(params)
    :edit -> Blog.update_post(socket.assigns.post, params)
  end
  |> case do
    {:ok, _post} ->
      {:noreply,
       socket
       |> put_flash(:info, "Post saved")
       |> push_navigate(to: ~p"/admin/blog/posts")}

    {:error, changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end

def handle_event("publish", %{"id" => id}, socket) do
  post = Blog.get_post!(id)

  case Blog.publish_post(post) do
    {:ok, _} ->
      {:noreply, put_flash(socket, :info, "Post published")}

    {:error, _} ->
      {:noreply, put_flash(socket, :error, "Could not publish")}
  end
end
```

### Pattern 2: Email Scheduling (Oban Worker)

```elixir
# lib/strive_planner/workers/email_scheduler.ex
defmodule StrivePlanner.Workers.EmailScheduler do
  use Oban.Worker, queue: :emails

  @impl Oban.Worker
  def perform(_job) do
    StrivePlanner.Blog.process_scheduled_emails()
    :ok
  end
end
```

### Pattern 3: Unsubscribe Flow

```elixir
# lib/strive_planner_web/controllers/newsletter/unsubscribe_controller.ex
defmodule StrivePlannerWeb.Newsletter.UnsubscribeController do
  use StrivePlannerWeb, :controller

  def unsubscribe(conn, %{"token" => token}) do
    case Phoenix.Token.verify(conn, "unsubscribe", token, max_age: :infinity) do
      {:ok, subscriber_id} ->
        StrivePlanner.Newsletter.unsubscribe(subscriber_id)

        render(conn, :unsubscribe,
          layout: {StrivePlannerWeb.Layouts, :minimal}
        )

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid unsubscribe link")
        |> redirect(to: ~p"/")
    end
  end
end
```

---

## Testing Quick Reference

### Context Tests

```elixir
# test/strive_planner/blog/blog_test.exs
describe "publish_post/1" do
  test "publishes draft post and sets published_at" do
    post = blog_post_fixture(%{status: "draft"})

    assert {:ok, published} = Blog.publish_post(post)
    assert published.status == "published"
    assert published.published_at != nil
  end

  test "does not publish already published post" do
    post = blog_post_fixture(%{status: "published"})

    assert {:error, changeset} = Blog.publish_post(post)
    assert changeset.errors[:status]
  end
end

describe "unpublish_post/1" do
  test "unpublishes post and cancels scheduled email" do
    post = blog_post_fixture(%{
      status: "published",
      scheduled_email_for: DateTime.utc_now() |> DateTime.add(3600)
    })

    assert {:ok, unpublished} = Blog.unpublish_post(post)
    assert unpublished.status == "draft"
    assert unpublished.scheduled_email_for == nil
  end
end
```

### LiveView Tests

```elixir
# test/strive_planner_web/live/admin/blog_post_live_test.exs
describe "Index" do
  test "publishes post when publish button clicked", %{conn: conn} do
    post = blog_post_fixture(%{status: "draft"})

    {:ok, index_live, _html} = live(conn, ~p"/admin/blog/posts")

    assert index_live
           |> element("#post-#{post.id} button", "Publish")
           |> render_click()

    # Verify post is published
    updated = Blog.get_post!(post.id)
    assert updated.status == "published"
  end
end
```

### Controller Tests

```elixir
# test/strive_planner_web/controllers/newsletter/unsubscribe_controller_test.exs
describe "unsubscribe/2" do
  test "unsubscribes user with valid token", %{conn: conn} do
    subscriber = subscriber_fixture()
    token = Phoenix.Token.sign(conn, "unsubscribe", subscriber.id)

    conn = get(conn, ~p"/unsubscribe?token=#{token}")

    assert html_response(conn, 200) =~ "unsubscribed"

    updated = Newsletter.get_subscriber!(subscriber.id)
    assert updated.subscription_status == "unsubscribed"
  end
end
```

---

## Debugging Tips

### Check Oban Jobs

```elixir
# In IEx
iex> Oban.Job |> Repo.all()
# List all jobs

iex> Oban.Job |> where([j], j.state == "scheduled") |> Repo.all()
# List scheduled jobs
```

### Manually Trigger Email Sending

```elixir
# In IEx
iex> StrivePlanner.Blog.process_scheduled_emails()
{:ok, 2} # 2 emails sent
```

### Check Subscriber Status

```elixir
# In IEx
iex> from(s in StrivePlanner.Newsletter.Subscriber,
...>   select: {s.email, s.verified, s.subscription_status})
...> |> Repo.all()

[
  {"user1@example.com", true, "subscribed"},
  {"user2@example.com", false, "subscribed"},
  {"user3@example.com", true, "unsubscribed"}
]
```

---

## File Checklist

When implementing this feature, you'll create/modify these files:

**Contexts**:
- [x] `lib/strive_planner/blog.ex` - Add publish, unpublish, schedule functions
- [x] `lib/strive_planner/newsletter.ex` - Add CRUD and unsubscribe functions

**Schemas**:
- [x] `lib/strive_planner/blog/blog_post.ex` - No schema changes (fields exist)
- [x] `lib/strive_planner/newsletter/subscriber.ex` - Add subscription_status field

**LiveViews**:
- [ ] `lib/strive_planner_web/live/admin/blog_post_live/index.ex` - Extend with email status
- [ ] `lib/strive_planner_web/live/admin/blog_post_live/form_component.ex` - Add scheduled_email_for
- [ ] `lib/strive_planner_web/live/admin/subscriber_live/index.ex` - NEW
- [ ] `lib/strive_planner_web/live/admin/subscriber_live/show.ex` - NEW
- [ ] `lib/strive_planner_web/live/admin/subscriber_live/form_component.ex` - NEW

**Controllers**:
- [ ] `lib/strive_planner_web/controllers/newsletter/unsubscribe_controller.ex` - NEW

**Workers**:
- [ ] `lib/strive_planner/workers/email_scheduler.ex` - NEW

**Templates**:
- [ ] `lib/strive_planner_web/controllers/newsletter/unsubscribe_html/unsubscribe.html.heex` - NEW

**Migrations**:
- [ ] `priv/repo/migrations/*_add_subscription_status_to_subscribers.exs` - NEW
- [ ] `priv/repo/migrations/*_add_scheduled_email_index_to_blog_posts.exs` - NEW

**Tests**:
- [ ] `test/strive_planner/blog/blog_test.exs` - Extend with new function tests
- [ ] `test/strive_planner/newsletter/newsletter_test.exs` - Extend with CRUD tests
- [ ] `test/strive_planner_web/live/admin/blog_post_live_test.exs` - Extend
- [ ] `test/strive_planner_web/live/admin/subscriber_live_test.exs` - NEW
- [ ] `test/strive_planner_web/controllers/newsletter/unsubscribe_controller_test.exs` - NEW

---

## Next Steps

After reviewing this quickstart:

1. Run `/speckit.tasks` to generate actionable tasks
2. Follow TDD workflow: Write tests first, then implementation
3. Refer to contracts/ directory for detailed API specifications
4. Refer to data-model.md for entity relationships and state machines

## Questions?

- Review `spec.md` for business requirements
- Review `research.md` for design decisions and rationale
- Review `data-model.md` for data structure details
- Review `contracts/` for API specifications
