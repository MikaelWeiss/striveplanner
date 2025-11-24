defmodule StrivePlannerWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug to ensure the current user is authenticated and has admin role.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      is_nil(user_id) ->
        conn
        |> put_flash(:error, "You must be signed in to access the admin portal.")
        |> redirect(to: "/admin/login")
        |> halt()

      true ->
        user = StrivePlanner.Accounts.get_user(user_id)

        cond do
          is_nil(user) ->
            conn
            |> clear_session()
            |> put_flash(:error, "Your session has expired. Please sign in again.")
            |> redirect(to: "/admin/login")
            |> halt()

          not StrivePlanner.Accounts.admin?(user) ->
            conn
            |> put_flash(:error, "You do not have permission to access the admin portal.")
            |> redirect(to: "/")
            |> halt()

          true ->
            assign(conn, :current_user, user)
        end
    end
  end
end
