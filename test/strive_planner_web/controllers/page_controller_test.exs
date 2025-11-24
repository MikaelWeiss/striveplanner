defmodule StrivePlannerWeb.PageControllerTest do
  use StrivePlannerWeb.ConnCase, async: true

  import StrivePlanner.BlogFixtures
  import StrivePlanner.NewsletterFixtures

  describe "GET /" do
    test "renders home page", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Shape Your Life"
    end

    test "returns 200 status", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert conn.status == 200
    end
  end

  describe "GET /about" do
    test "renders about page", %{conn: conn} do
      conn = get(conn, ~p"/about")
      response = html_response(conn, 200)
      assert response =~ "About"
    end

    test "returns 200 status", %{conn: conn} do
      conn = get(conn, ~p"/about")
      assert conn.status == 200
    end
  end

  describe "GET /blog" do
    test "lists published blog posts", %{conn: conn} do
      _published = published_post_fixture(%{title: "Published Post"})
      _draft = blog_post_fixture(%{title: "Draft Post", status: "draft"})

      conn = get(conn, ~p"/blog")
      response = html_response(conn, 200)

      assert response =~ "Published Post"
      refute response =~ "Draft Post"
    end

    test "does not show draft posts", %{conn: conn} do
      _draft = blog_post_fixture(%{title: "Secret Draft", status: "draft"})

      conn = get(conn, ~p"/blog")
      response = html_response(conn, 200)

      refute response =~ "Secret Draft"
    end
  end

  describe "GET /blog/:slug" do
    test "shows published blog post", %{conn: conn} do
      post = published_post_fixture(%{title: "Test Post", slug: "test-post"})

      conn = get(conn, ~p"/blog/#{post.slug}")
      response = html_response(conn, 200)

      assert response =~ "Test Post"
    end

    test "increments view count", %{conn: conn} do
      post = published_post_fixture(%{title: "Popular Post"})

      initial_count = post.view_count

      conn = get(conn, ~p"/blog/#{post.slug}")
      assert html_response(conn, 200)

      # Fetch post again and verify view count increased
      updated_post = StrivePlanner.Blog.get_post!(post.id)
      assert updated_post.view_count == initial_count + 1
    end

    test "renders markdown content", %{conn: conn} do
      post =
        published_post_fixture(%{
          title: "Markdown Post",
          content: "# Heading\n\nParagraph with **bold** text."
        })

      conn = get(conn, ~p"/blog/#{post.slug}")
      response = html_response(conn, 200)

      # Should contain rendered HTML from markdown
      assert response =~ "<h1>"
      assert response =~ "Heading"
      assert response =~ "<strong>bold</strong>"
    end

    test "returns 404 for draft post", %{conn: conn} do
      draft = blog_post_fixture(%{title: "Draft", slug: "draft-slug", status: "draft"})

      conn = get(conn, ~p"/blog/#{draft.slug}")
      assert conn.status == 404
    end

    test "returns 404 for non-existent post", %{conn: conn} do
      conn = get(conn, ~p"/blog/nonexistent-slug")
      assert conn.status == 404
    end
  end

  describe "GET /newsletter/verify/:token" do
    test "verifies subscriber with valid token", %{conn: conn} do
      subscriber = subscriber_with_token_fixture()

      conn = get(conn, ~p"/newsletter/verify/#{subscriber.verification_token}")

      # Should redirect to welcome page
      assert redirected_to(conn) == ~p"/newsletter/welcome"

      # Verify subscriber is now verified
      updated = StrivePlanner.Newsletter.get_subscriber_by_email(subscriber.email)
      assert updated.verified == true
    end

    test "shows error for invalid token", %{conn: conn} do
      conn = get(conn, ~p"/newsletter/verify/invalid-token-xyz")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "invalid"
    end

    test "shows error for expired token", %{conn: conn} do
      subscriber = subscriber_fixture()

      # Create expired token
      expired_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
      expired_at = DateTime.add(DateTime.utc_now(), -3600, :second)

      subscriber
      |> StrivePlanner.Newsletter.Subscriber.verification_changeset(%{
        verification_token: expired_token,
        verification_token_expires_at: expired_at
      })
      |> StrivePlanner.Repo.update!()

      conn = get(conn, ~p"/newsletter/verify/#{expired_token}")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "expired"
    end
  end

  describe "GET /newsletter/welcome" do
    test "renders welcome page", %{conn: conn} do
      conn = get(conn, ~p"/newsletter/welcome")
      response = html_response(conn, 200)

      assert response =~ "Welcome" || response =~ "welcome"
    end
  end
end
