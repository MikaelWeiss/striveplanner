defmodule StrivePlannerWeb.API.NewsletterControllerTest do
  use StrivePlannerWeb.ConnCase, async: true

  describe "POST /api/newsletter/subscribe" do
    test "returns error for invalid email format", %{conn: conn} do
      params = %{"email" => "invalid-email"}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] =~ "valid email"
    end

    test "returns error for missing email", %{conn: conn} do
      params = %{}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 400)
      response = json_response(conn, 400)
      assert response["error"] =~ "required"
    end

    test "validates email with @ symbol", %{conn: conn} do
      params = %{"email" => "notanemail"}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 400)
    end

    test "validates email with domain", %{conn: conn} do
      params = %{"email" => "test@"}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 400)
    end
  end
end
