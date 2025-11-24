defmodule StrivePlanner.Workers.EmailSchedulerTest do
  use StrivePlanner.DataCase, async: true
  use Oban.Testing, repo: StrivePlanner.Repo

  alias StrivePlanner.Workers.EmailScheduler

  # I don't have any tests to actually call the Resend API, which is 100% intentional. I don't want to call the Resend API in testing.
  describe "perform/1" do
    test "succeeds even when no emails are due" do
      assert :ok = perform_job(EmailScheduler, %{})
    end
  end
end
