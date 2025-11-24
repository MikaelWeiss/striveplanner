defmodule StrivePlanner.BlogFixtures do
  @moduledoc """
  This module defines test fixtures for Blog context.

  Fixtures create reusable test data for blog post and comment testing.
  All fixtures use unique titles to prevent slug conflicts in async tests.
  """

  alias StrivePlanner.Blog
  alias StrivePlanner.Repo

  @doc """
  Creates a draft blog post with a unique title.

  ## Examples

      iex> post = blog_post_fixture()
      iex> post.status
      "draft"

      iex> post = blog_post_fixture(%{title: "Custom Title"})
      iex> post.title
      "Custom Title"

  """
  def blog_post_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    {:ok, post} =
      attrs
      |> Enum.into(%{
        title: "Test Blog Post #{unique_id}",
        content: "This is test content for blog post #{unique_id}.",
        status: "draft"
      })
      |> Blog.create_post()

    post
  end

  @doc """
  Creates a published blog post.

  ## Examples

      iex> post = published_post_fixture()
      iex> post.status
      "published"
      iex> post.published_at
      ~U[...]

  """
  def published_post_fixture(attrs \\ %{}) do
    # If attrs contains scheduled_email_for, we need to handle it separately
    # because it might be in the past (for testing purposes)
    {scheduled_email_for, attrs} = Map.pop(attrs, :scheduled_email_for)

    base_attrs =
      attrs
      |> Map.merge(%{
        status: "published",
        published_at: DateTime.utc_now()
      })

    post = blog_post_fixture(base_attrs)

    # If scheduled_email_for was provided, update it directly using Ecto (bypassing validation)
    if scheduled_email_for do
      # Truncate to remove microseconds (required by Ecto)
      scheduled_time = DateTime.truncate(scheduled_email_for, :second)

      post
      |> Ecto.Changeset.change(%{scheduled_email_for: scheduled_time})
      |> Repo.update!()
    else
      post
    end
  end

  @doc """
  Creates a published blog post with a specified view count.

  ## Examples

      iex> post = post_with_views_fixture(%{view_count: 42})
      iex> post.view_count
      42

  """
  def post_with_views_fixture(attrs \\ %{}) do
    view_count = Map.get(attrs, :view_count, 10)

    post = published_post_fixture(attrs)

    # Update view count directly using Ecto
    post
    |> Ecto.Changeset.change(view_count: view_count)
    |> Repo.update!()
  end

  @doc """
  Creates a blog post with a scheduled email date.

  ## Examples

      iex> post = scheduled_email_post_fixture()
      iex> post.scheduled_email_for
      ~U[...]

  """
  def scheduled_email_post_fixture(attrs \\ %{}) do
    scheduled_for = DateTime.utc_now() |> DateTime.add(3600, :second)

    attrs
    |> Map.merge(%{
      status: "published",
      published_at: DateTime.utc_now(),
      scheduled_email_for: scheduled_for
    })
    |> blog_post_fixture()
  end

  @doc """
  Creates a comment for a blog post.

  ## Examples

      iex> post = blog_post_fixture()
      iex> user = StrivePlanner.AccountsFixtures.user_fixture()
      iex> comment = comment_fixture(post, user)
      iex> comment.content
      "Test comment..."

  """
  def comment_fixture(blog_post, user, attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    comment_attrs =
      attrs
      |> Enum.into(%{
        content: "Test comment #{unique_id}",
        blog_post_id: blog_post.id,
        user_id: user.id
      })

    %StrivePlanner.Blog.Comment{}
    |> StrivePlanner.Blog.Comment.changeset(comment_attrs)
    |> Repo.insert!()
  end
end
