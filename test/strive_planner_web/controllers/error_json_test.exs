defmodule StrivePlannerWeb.ErrorJSONTest do
  use StrivePlannerWeb.ConnCase, async: true

  test "renders 404" do
    assert StrivePlannerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert StrivePlannerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
