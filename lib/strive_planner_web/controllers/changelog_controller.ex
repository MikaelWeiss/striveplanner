defmodule StrivePlannerWeb.ChangelogController do
  use StrivePlannerWeb, :controller

  def index(conn, _params) do
    changelog = [
      %{
        version: "1.0.7",
        date: "2025-01-30T00:00:00Z",
        changes: [
          %{type: "Added", description: "Added badge to settings for when there is a newer version"},
          %{type: "Added", description: "Added notifications"},
          %{type: "Added", description: "You can now add new event type while editing an event"},
          %{type: "Added", description: "Added a date picker when you tap the date in the Calendar View"}
        ]
      },
      %{
        version: "1.0.6",
        date: "2025-01-24T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Fixed some cosmetics"},
          %{type: "Added", description: "Added recurrence end"},
          %{type: "Added", description: "Added some fun haptics"}
        ]
      },
      %{
        version: "1.0.5",
        date: "2025-01-22T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Fixed drag and drop"},
          %{type: "Fixed", description: "Fixed some other bugs"}
        ]
      },
      %{
        version: "1.0.4",
        date: "2025-01-20T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Lots of bug fixes"},
          %{type: "Changed", description: "Lots of UI improvements"}
        ]
      },
      %{
        version: "1.0.3",
        date: "2025-01-16T00:00:00Z",
        changes: [
          %{type: "Changed", description: "Updated app icon"}
        ]
      },
      %{
        version: "1.0.2",
        date: "2025-01-14T00:00:00Z",
        changes: [
          %{type: "Added", description: "Added timelines for people"},
          %{type: "Added", description: "Can now add people to events"}
        ]
      },
      %{
        version: "1.0.1",
        date: "2025-01-07T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Squashed some bugs"}
        ]
      },
      %{
        version: "1.0.0",
        date: "2025-01-06T00:00:00Z",
        changes: [
          %{type: "Added", description: "First release!"}
        ]
      }
    ]

    json(conn, changelog)
  end
end
