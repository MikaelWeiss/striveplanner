defmodule StrivePlannerWeb.ChangelogController do
  use StrivePlannerWeb, :controller

  def index(conn, _params) do
    changelog = [
      %{
        version: "1.0.9",
        date: "2025-02-18T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Fixed bug where dragging an event would sometimes make it show up on the next day"},
          %{type: "Fixed", description: "Fixed bug where new events would sometimes end up on the next day"},
          %{type: "Fixed", description: "Various bug fixes"},
          %{type: "Added", description: "Added iCloud sync status to settings"},
          %{type: "Added", description: "Added clock time picker"},
          %{type: "Added", description: "Made it easier to select more than one person at a time when editing an event"},
          %{type: "Added", description: "Made it easier to select more than one goal at a time when editing an event"},
          %{type: "Added", description: "Added better details when viewing a person's timeline"},
          %{type: "Changed", description: "Organized the settings a little more"}
        ]
      },
      %{
        version: "1.0.8",
        date: "2025-02-04T00:00:00Z",
        changes: [
          %{type: "Fixed", description: "Fixed some bugs"},
          %{type: "Fixed", description: "Fixed bug where custom colors wasn't working for some users"},
          %{type: "Added", description: "Added ability to call/text from in app"},
          %{type: "Added", description: "Profile pictures for imported contacts now show"},
          %{type: "Added", description: "When call/text and return to app, opens report contact"},
          %{type: "Changed", description: "Improved search for people"}
        ]
      },
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
