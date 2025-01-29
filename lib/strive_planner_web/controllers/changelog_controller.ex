defmodule StrivePlannerWeb.ChangelogController do
  use StrivePlannerWeb, :controller

  def index(conn, _params) do
    changelog = [
      %{
        version: "1.0.6",
        date: "2025-01-24",
        changes: [
          %{type: "Fixed", description: "Fixed some cosmetics"},
          %{type: "Added", description: "Added recurrence end"},
          %{type: "Added", description: "Added some fun haptics"}
        ]
      },
      %{
        version: "1.0.5",
        date: "2025-01-22",
        changes: [
          %{type: "Fixed", description: "Fixed drag and drop"},
          %{type: "Fixed", description: "Fixed some other bugs"}
        ]
      },
      %{
        version: "1.0.4",
        date: "2025-01-20",
        changes: [
          %{type: "Fixed", description: "Lots of bug fixes"},
          %{type: "Changed", description: "Lots of UI improvements"}
        ]
      },
      %{
        version: "1.0.3",
        date: "2025-01-16",
        changes: [
          %{type: "Changed", description: "Updated app icon"}
        ]
      },
      %{
        version: "1.0.2",
        date: "2025-01-14",
        changes: [
          %{type: "Added", description: "Added timelines for people"},
          %{type: "Added", description: "Can now add people to events"}
        ]
      },
      %{
        version: "1.0.1",
        date: "2025-01-07",
        changes: [
          %{type: "Fixed", description: "Squashed some bugs"}
        ]
      },
      %{
        version: "1.0.0",
        date: "2025-01-06",
        changes: [
          %{type: "Added", description: "First release!"}
        ]
      }
    ]

    json(conn, changelog)
  end
end
