defmodule StrivePlannerWeb.AdminController do
  use StrivePlannerWeb, :controller

  def verify(conn, %{"token" => token}) do
    case StrivePlanner.Accounts.verify_admin_magic_link(token) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome back, #{user.email}!")
        |> redirect(to: "/admin")

      {:error, :invalid_or_expired_token} ->
        conn
        |> put_flash(
          :error,
          "This sign-in link is invalid or has expired. Please request a new one."
        )
        |> redirect(to: "/admin/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been signed out.")
    |> redirect(to: "/")
  end
end
