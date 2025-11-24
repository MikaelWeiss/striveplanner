defmodule StrivePlanner.Workers.EmailScheduler do
  @moduledoc """
  Oban worker that processes scheduled blog post emails.

  This worker runs every minute (configured in Oban cron) and sends
  blog post notifications to subscribers for posts with scheduled_email_for
  in the past that haven't been sent yet.

  ## Configuration

  Configured in config/config.exs:

      config :strive_planner, Oban,
        plugins: [
          {Oban.Plugins.Cron,
           crontab: [
             {"* * * * *", StrivePlanner.Workers.EmailScheduler}
           ]}
        ]

  """
  use Oban.Worker, queue: :emails

  @impl Oban.Worker
  def perform(_job) do
    StrivePlanner.Blog.process_scheduled_emails()
    :ok
  end
end
