defmodule StrivePlannerWeb.BlogController do
  use StrivePlannerWeb, :controller
  alias StrivePlanner.Blog

  def index(conn, _params) do
    posts = Blog.list_posts()
    render(conn, :index, posts: posts)
  end

  def show(conn, %{"slug" => slug}) do
    case Blog.get_post_by_slug(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(StrivePlannerWeb.ErrorHTML)
        |> render(:"404")

      post ->
        render(conn, :show, post: post)
    end
  end
end