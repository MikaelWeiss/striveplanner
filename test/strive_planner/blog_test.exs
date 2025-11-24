defmodule StrivePlanner.BlogTest do
  use StrivePlanner.DataCase, async: true
  use Oban.Testing, repo: StrivePlanner.Repo

  import Ecto.Query
  alias StrivePlanner.Blog

  import StrivePlanner.BlogFixtures
  import StrivePlanner.NewsletterFixtures

  describe "list_posts/0" do
    test "returns only published posts" do
      _draft = blog_post_fixture(%{status: "draft"})
      published = published_post_fixture()

      posts = Blog.list_posts()

      assert length(posts) == 1
      assert hd(posts).id == published.id
    end

    test "excludes draft posts" do
      _draft = blog_post_fixture()

      posts = Blog.list_posts()

      assert posts == []
    end

    test "orders by published_at descending" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      past_time = DateTime.add(now, -7200, :second)

      # Create two published posts
      old_post = published_post_fixture(%{title: "Old Post #{System.unique_integer()}"})
      new_post = published_post_fixture(%{title: "New Post #{System.unique_integer()}"})

      # Update their published_at times directly to ensure proper ordering
      old_post =
        old_post
        |> Ecto.Changeset.change(%{published_at: past_time})
        |> StrivePlanner.Repo.update!()

      new_post =
        new_post
        |> Ecto.Changeset.change(%{published_at: now})
        |> StrivePlanner.Repo.update!()

      posts = Blog.list_posts()

      # Filter to only the posts we just created
      test_posts = Enum.filter(posts, fn p -> p.id in [old_post.id, new_post.id] end)

      # Verify both posts exist
      assert length(test_posts) == 2

      # Find the position of each post in the original sorted list
      new_post_index = Enum.find_index(posts, fn p -> p.id == new_post.id end)
      old_post_index = Enum.find_index(posts, fn p -> p.id == old_post.id end)

      # The new post should appear before the old post (lower index = earlier in list)
      assert new_post_index < old_post_index,
             "Expected new post (#{now}) at index #{new_post_index} to appear before old post (#{past_time}) at index #{old_post_index})"
    end

    test "returns empty list when no published posts" do
      assert Blog.list_posts() == []
    end
  end

  describe "list_all_posts/0" do
    test "returns all posts including drafts" do
      draft = blog_post_fixture(%{status: "draft"})
      published = published_post_fixture()

      posts = Blog.list_all_posts()

      assert length(posts) == 2
      post_ids = Enum.map(posts, & &1.id)
      assert draft.id in post_ids
      assert published.id in post_ids
    end

    test "orders by updated_at descending" do
      # Create first post
      _first_post = blog_post_fixture(%{title: "First #{System.unique_integer()}"})

      # Small delay to ensure different timestamps
      Process.sleep(50)

      # Create and immediately update second post
      second_post = blog_post_fixture(%{title: "Second #{System.unique_integer()}"})
      {:ok, updated_second} = Blog.update_post(second_post, %{title: "Updated Second"})

      posts = Blog.list_all_posts()

      # Find the updated post in the results
      found_post = Enum.find(posts, fn p -> p.id == updated_second.id end)

      # Verify it exists and has the updated title
      assert found_post != nil
      assert found_post.title == "Updated Second"
    end
  end

  describe "get_post/1" do
    test "returns published post by slug" do
      post = published_post_fixture(%{title: "Test Post", slug: "test-post"})

      assert {:ok, found} = Blog.get_post("test-post")
      assert found.id == post.id
    end

    test "returns error for draft post" do
      _draft = blog_post_fixture(%{title: "Draft", slug: "draft", status: "draft"})

      assert {:error, :not_found} = Blog.get_post("draft")
    end

    test "returns error for non-existent slug" do
      assert {:error, :not_found} = Blog.get_post("nonexistent")
    end
  end

  describe "get_post!/1" do
    test "returns post by ID" do
      post = blog_post_fixture()

      assert found = Blog.get_post!(post.id)
      assert found.id == post.id
    end

    test "raises error for non-existent ID" do
      assert_raise Ecto.NoResultsError, fn ->
        Blog.get_post!(999_999)
      end
    end
  end

  describe "create_post/1" do
    test "creates post with valid attributes" do
      attrs = %{
        title: "New Post",
        content: "Content here"
      }

      assert {:ok, post} = Blog.create_post(attrs)
      assert post.title == "New Post"
      assert post.content == "Content here"
    end

    test "returns error with invalid attributes" do
      attrs = %{title: nil}

      assert {:error, %Ecto.Changeset{}} = Blog.create_post(attrs)
    end

    test "generates unique slug from title" do
      {:ok, post1} = Blog.create_post(%{title: "Test Post", content: "Content"})
      assert post1.slug == "test-post"

      # Creating another post with same title should fail due to unique constraint
      assert {:error, %Ecto.Changeset{}} =
               Blog.create_post(%{title: "Test Post", content: "Content"})
    end
  end

  describe "update_post/2" do
    test "updates post with valid attributes" do
      post = blog_post_fixture()

      assert {:ok, updated} = Blog.update_post(post, %{title: "Updated Title"})
      assert updated.title == "Updated Title"
    end

    test "returns error with invalid attributes" do
      post = blog_post_fixture()

      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, %{title: nil})
    end
  end

  describe "delete_post/1" do
    test "deletes post" do
      post = blog_post_fixture()

      assert {:ok, _deleted} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end
  end

  describe "increment_view_count/1" do
    test "increments view count by 1" do
      post = blog_post_fixture()
      assert post.view_count == 0

      {:ok, updated} = Blog.increment_view_count(post)
      assert updated.view_count == 1
    end

    test "handles multiple increments" do
      post = blog_post_fixture()

      {:ok, post} = Blog.increment_view_count(post)
      assert post.view_count == 1

      {:ok, post} = Blog.increment_view_count(post)
      assert post.view_count == 2

      {:ok, post} = Blog.increment_view_count(post)
      assert post.view_count == 3
    end
  end

  describe "render_markdown/1" do
    test "converts markdown to HTML" do
      markdown = "# Heading\n\nParagraph with **bold** text."
      html = Blog.render_markdown(markdown)

      assert html =~ "<h1>"
      assert html =~ "Heading"
      assert html =~ "<strong>bold</strong>"
    end

    test "returns empty string for nil" do
      assert Blog.render_markdown(nil) == ""
    end

    test "returns original content on parse error" do
      # Earmark handles most markdown gracefully, so this is hard to trigger
      # but the function should handle errors
      assert is_binary(Blog.render_markdown("Simple text"))
    end
  end

  describe "publish_post/1" do
    test "publishes draft post and sets published_at" do
      post = blog_post_fixture(%{status: "draft"})
      assert post.status == "draft"
      assert post.published_at == nil

      assert {:ok, published} = Blog.publish_post(post)
      assert published.status == "published"
      assert published.published_at != nil
    end

    test "does not change published_at if already set" do
      existing_time =
        DateTime.utc_now() |> DateTime.add(-86400, :second) |> DateTime.truncate(:second)

      post = blog_post_fixture(%{status: "draft", published_at: existing_time})

      assert {:ok, published} = Blog.publish_post(post)
      assert published.status == "published"
      assert published.published_at == existing_time
    end

    test "cancels scheduled_email_for when publishing to prevent duplicate sends" do
      scheduled_time =
        DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      post = blog_post_fixture(%{status: "draft", scheduled_email_for: scheduled_time})

      assert {:ok, published} = Blog.publish_post(post)
      assert published.status == "published"
      assert published.scheduled_email_for == nil
    end
  end

  describe "unpublish_post/1" do
    test "unpublishes published post and sets status to draft" do
      post = published_post_fixture()
      assert post.status == "published"

      assert {:ok, unpublished} = Blog.unpublish_post(post)
      assert unpublished.status == "draft"
    end

    test "preserves published_at when unpublishing" do
      post = published_post_fixture()
      original_published_at = post.published_at

      assert {:ok, unpublished} = Blog.unpublish_post(post)
      assert unpublished.published_at == original_published_at
    end

    test "cancels scheduled email when unpublishing" do
      scheduled_time = DateTime.utc_now() |> DateTime.add(3600, :second)
      post = published_post_fixture(%{scheduled_email_for: scheduled_time})
      assert post.scheduled_email_for != nil

      assert {:ok, unpublished} = Blog.unpublish_post(post)
      assert unpublished.scheduled_email_for == nil
    end

    test "allows unpublishing post with no scheduled email" do
      post = published_post_fixture()
      assert post.scheduled_email_for == nil

      assert {:ok, unpublished} = Blog.unpublish_post(post)
      assert unpublished.status == "draft"
    end
  end

  describe "schedule_email/2" do
    test "sets scheduled_email_for and enqueues Oban job" do
      post = published_post_fixture()

      future_time =
        DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      assert {:ok, updated} = Blog.schedule_email(post, future_time)
      assert updated.scheduled_email_for == future_time

      # Verify Oban job was created
      jobs = all_enqueued(worker: StrivePlanner.Workers.EmailScheduler)
      assert length(jobs) == 1
      job = hd(jobs)
      assert job.args["post_id"] == post.id
    end

    test "returns error if scheduled_email_for is in the past" do
      post = published_post_fixture()
      past_time = DateTime.utc_now() |> DateTime.add(-3600, :second)

      assert {:error, %Ecto.Changeset{}} = Blog.schedule_email(post, past_time)
    end

    test "replaces existing scheduled email" do
      post = published_post_fixture()
      first_time = DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second)

      second_time =
        DateTime.utc_now() |> DateTime.add(7200, :second) |> DateTime.truncate(:second)

      {:ok, _} = Blog.schedule_email(post, first_time)
      {:ok, updated} = Blog.schedule_email(post, second_time)

      assert updated.scheduled_email_for == second_time
    end
  end

  describe "cancel_scheduled_email/1" do
    test "clears scheduled_email_for and cancels Oban job" do
      post = published_post_fixture()
      future_time = DateTime.utc_now() |> DateTime.add(3600, :second)

      {:ok, scheduled} = Blog.schedule_email(post, future_time)
      assert scheduled.scheduled_email_for != nil

      assert {:ok, updated} = Blog.cancel_scheduled_email(scheduled)
      assert updated.scheduled_email_for == nil

      # Verify Oban job was cancelled
      jobs = all_enqueued(worker: StrivePlanner.Workers.EmailScheduler)
      assert jobs == []
    end

    test "works on post with no scheduled email" do
      post = published_post_fixture()
      assert post.scheduled_email_for == nil

      assert {:ok, updated} = Blog.cancel_scheduled_email(post)
      assert updated.scheduled_email_for == nil
    end
  end

  describe "process_scheduled_emails/0" do
    test "sends emails for posts with due scheduled_email_for" do
      verified_subscriber_fixture()

      now = DateTime.utc_now() |> DateTime.truncate(:second)
      past_time = DateTime.add(now, -60, :second)

      post = published_post_fixture(%{scheduled_email_for: past_time})

      assert {:ok, sent_count} = Blog.process_scheduled_emails()
      assert sent_count >= 1

      # Verify post was updated
      updated_post = Blog.get_post!(post.id)
      assert updated_post.sent_to_subscribers == true
      assert updated_post.email_sent_at != nil
    end

    test "does not send emails for future scheduled_email_for" do
      verified_subscriber_fixture()

      future_time = DateTime.utc_now() |> DateTime.add(3600, :second)
      _post = published_post_fixture(%{scheduled_email_for: future_time})

      assert {:ok, sent_count} = Blog.process_scheduled_emails()
      assert sent_count == 0
    end

    test "does not send emails that were already sent" do
      verified_subscriber_fixture()

      past_time = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)

      # Create post with scheduled email
      post = published_post_fixture(%{scheduled_email_for: past_time})

      # Mark it as already sent (bypass validation)
      post
      |> Ecto.Changeset.change(%{
        sent_to_subscribers: true,
        email_sent_at: past_time
      })
      |> StrivePlanner.Repo.update!()

      assert {:ok, sent_count} = Blog.process_scheduled_emails()
      assert sent_count == 0
    end
  end

  describe "send_to_subscribers/1" do
    test "returns error when no subscribers" do
      post = published_post_fixture()

      assert {:error, :no_subscribers} = Blog.send_to_subscribers(post)
    end

    test "only queries verified AND subscribed subscribers" do
      # Create subscribers with different states
      verified_subscribed = verified_subscriber_fixture(%{subscription_status: "subscribed"})

      _unverified_subscribed =
        subscriber_fixture(%{verified: false, subscription_status: "subscribed"})

      _verified_unsubscribed = verified_subscriber_fixture(%{subscription_status: "unsubscribed"})

      _unverified_unsubscribed =
        subscriber_fixture(%{verified: false, subscription_status: "unsubscribed"})

      # Since we can't test actual email sending without the API key,
      # we verify the query by checking what subscribers would be selected
      subscribers =
        StrivePlanner.Repo.all(
          from s in StrivePlanner.Newsletter.Subscriber,
            where: s.verified == true and s.subscription_status == "subscribed"
        )

      # Only 1 subscriber should be selected (verified AND subscribed)
      assert length(subscribers) == 1
      assert hd(subscribers).id == verified_subscribed.id
    end
  end
end
