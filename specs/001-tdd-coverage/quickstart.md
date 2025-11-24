# Quickstart: Test-Driven Development Implementation

**Feature**: 001-tdd-coverage
**Date**: 2025-10-23
**Branch**: `001-tdd-coverage`

## Overview

This quickstart guide helps you implement comprehensive test coverage for the StrivePlanner application using test-driven development practices.

## Prerequisites

- Elixir 1.15+ installed
- PostgreSQL running (for test database)
- Phoenix application dependencies installed (`mix deps.get`)
- Test database created (`mix ecto.create`)

## Quick Setup

```bash
# Ensure you're on the feature branch
git checkout 001-tdd-coverage

# Install dependencies (if not already done)
mix deps.get

# Create and migrate test database
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate

# Run existing tests to verify setup
mix test
```

## Implementation Order

Follow this order to implement test coverage in logical dependency order:

### Phase 1: Test Fixtures (P4 - Foundation)

**Why first**: Other tests depend on fixtures for creating test data

**Files to create**:
1. `test/support/fixtures/newsletter_fixtures.ex`
2. `test/support/fixtures/accounts_fixtures.ex`
3. `test/support/fixtures/blog_fixtures.ex`

**Example fixture**:
```elixir
# test/support/fixtures/newsletter_fixtures.ex
defmodule StrivePlanner.NewsletterFixtures do
  @moduledoc """
  Test fixtures for newsletter context.
  """

  def subscriber_fixture(attrs \\ %{}) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(%{
        email: "test-#{System.unique_integer()}@example.com",
        verified: false
      })
      |> StrivePlanner.Newsletter.create_subscriber()

    subscriber
  end

  def verified_subscriber_fixture(attrs \\ %{}) do
    subscriber_fixture(Map.put(attrs, :verified, true))
  end
end
```

**Verification**:
```bash
# Should compile without errors
mix compile
```

---

### Phase 2: Context Tests (P1 - Core Business Logic)

**Why second**: Core business logic is the foundation for everything else

**Files to create**:
1. `test/strive_planner/newsletter_test.exs`
2. `test/strive_planner/accounts_test.exs`
3. `test/strive_planner/blog_test.exs`

**Example context test**:
```elixir
# test/strive_planner/newsletter_test.exs
defmodule StrivePlanner.NewsletterTest do
  use StrivePlanner.DataCase, async: true

  alias StrivePlanner.Newsletter

  import StrivePlanner.NewsletterFixtures

  describe "create_subscriber/1" do
    test "creates subscriber with valid email" do
      attrs = %{email: "test@example.com"}

      assert {:ok, subscriber} = Newsletter.create_subscriber(attrs)
      assert subscriber.email == "test@example.com"
      assert subscriber.verified == false
    end

    test "returns error with invalid email" do
      attrs = %{email: "invalid"}

      assert {:error, %Ecto.Changeset{}} = Newsletter.create_subscriber(attrs)
    end

    test "returns error with duplicate email" do
      subscriber = subscriber_fixture()

      assert {:error, %Ecto.Changeset{}} =
        Newsletter.create_subscriber(%{email: subscriber.email})
    end
  end

  describe "get_subscriber_by_email/1" do
    test "returns subscriber when email exists" do
      subscriber = subscriber_fixture()

      assert found = Newsletter.get_subscriber_by_email(subscriber.email)
      assert found.id == subscriber.id
    end

    test "returns nil when email does not exist" do
      assert Newsletter.get_subscriber_by_email("nonexistent@example.com") == nil
    end
  end
end
```

**Verification**:
```bash
# Run context tests
mix test test/strive_planner/

# Check coverage
mix test test/strive_planner/ --cover
```

---

### Phase 3: Controller Tests (P2 - User-Facing Features)

**Why third**: Build on context tests to verify HTTP layer

**Files to create/update**:
1. `test/strive_planner_web/controllers/page_controller_test.exs` (expand existing)
2. `test/strive_planner_web/controllers/api/newsletter_controller_test.exs` (new)

**Example controller test**:
```elixir
# test/strive_planner_web/controllers/api/newsletter_controller_test.exs
defmodule StrivePlannerWeb.API.NewsletterControllerTest do
  use StrivePlannerWeb.ConnCase, async: true

  import Swoosh.TestAssertions
  import StrivePlanner.NewsletterFixtures

  describe "POST /api/newsletter/subscribe" do
    test "creates subscriber and sends verification email", %{conn: conn} do
      params = %{"email" => "test@example.com"}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 200)

      # Verify subscriber created
      assert StrivePlanner.Newsletter.email_subscribed?("test@example.com")

      # Verify email sent
      assert_email_sent(subject: "Verify your subscription")
    end

    test "returns error for invalid email", %{conn: conn} do
      params = %{"email" => "invalid"}

      conn = post(conn, ~p"/api/newsletter/subscribe", params)

      assert json_response(conn, 422)
    end
  end
end
```

**Verification**:
```bash
# Run controller tests
mix test test/strive_planner_web/controllers/

# Check coverage
mix test test/strive_planner_web/controllers/ --cover
```

---

### Phase 4: LiveView Tests (P3 - Admin Portal)

**Why fourth**: Admin features build on authentication tested in P1

**Files to create**:
1. `test/strive_planner_web/live/admin/login_live_test.exs`
2. `test/strive_planner_web/live/admin/dashboard_live_test.exs`

**Example LiveView test**:
```elixir
# test/strive_planner_web/live/admin/login_live_test.exs
defmodule StrivePlannerWeb.Admin.LoginLiveTest do
  use StrivePlannerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions
  import StrivePlanner.AccountsFixtures

  describe "admin login" do
    test "renders login form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/login")

      assert html =~ "Admin Login"
      assert html =~ "email"
    end

    test "sends magic link to admin user", %{conn: conn} do
      admin = admin_fixture(%{email: "admin@example.com"})

      {:ok, view, _html} = live(conn, ~p"/admin/login")

      view
      |> form("#login-form", %{email: admin.email})
      |> render_submit()

      assert_email_sent(
        subject: "Your login link",
        to: [{nil, admin.email}]
      )
    end

    test "returns error for non-admin user", %{conn: conn} do
      user = user_fixture(%{email: "user@example.com"})

      {:ok, view, _html} = live(conn, ~p"/admin/login")

      html =
        view
        |> form("#login-form", %{email: user.email})
        |> render_submit()

      assert html =~ "not found or not an admin"
    end
  end
end
```

**Verification**:
```bash
# Run LiveView tests
mix test test/strive_planner_web/live/

# Check coverage
mix test test/strive_planner_web/live/ --cover
```

---

## Running Tests

### Run All Tests
```bash
mix test
```

### Run Specific Test File
```bash
mix test test/strive_planner/newsletter_test.exs
```

### Run Specific Test
```bash
mix test test/strive_planner/newsletter_test.exs:10
```

### Run Tests with Coverage
```bash
mix test --cover
```

### Run Failed Tests Only
```bash
mix test --failed
```

### Run Slowest Tests
```bash
mix test --slowest
```

### Run Tests in Watch Mode
```bash
# Install mix_test_watch dependency first
mix test.watch
```

---

## TDD Workflow

For **new features** (after this initial test coverage):

### 1. Red Phase - Write Failing Test

```elixir
test "new feature does X" do
  # Arrange
  subscriber = subscriber_fixture()

  # Act
  result = Newsletter.new_feature(subscriber)

  # Assert
  assert result == :expected_value
end
```

Run test - it should **fail** (Red):
```bash
mix test test/strive_planner/newsletter_test.exs:45
# Expected: failure because new_feature/1 doesn't exist yet
```

### 2. Green Phase - Make Test Pass

Implement minimum code to make test pass:

```elixir
# lib/strive_planner/newsletter.ex
def new_feature(subscriber) do
  :expected_value
end
```

Run test - it should **pass** (Green):
```bash
mix test test/strive_planner/newsletter_test.exs:45
# Expected: success
```

### 3. Refactor Phase - Improve Code

Refactor while keeping tests green:
- Extract helper functions
- Improve naming
- Add error handling
- Optimize performance

Run tests continuously:
```bash
mix test
# All tests should remain green
```

---

## Coverage Goals

### Target: 90%+ Coverage for Context Modules

Check current coverage:
```bash
mix test --cover
```

Focus on:
- ✅ All public context functions
- ✅ Happy path scenarios
- ✅ Error scenarios
- ✅ Edge cases (duplicates, expired tokens, etc.)

Acceptable to skip:
- Private helper functions (tested via public API)
- Generated boilerplate
- Unreachable error branches

---

## Common Patterns

### Setup Block for Shared Data

```elixir
describe "feature group" do
  setup do
    subscriber = subscriber_fixture()
    %{subscriber: subscriber}
  end

  test "uses setup data", %{subscriber: subscriber} do
    # subscriber available here
  end
end
```

### Testing Email Delivery

```elixir
import Swoosh.TestAssertions

test "sends email" do
  # Trigger email send
  Newsletter.send_welcome_email(subscriber)

  # Verify email sent
  assert_email_sent(
    subject: "Welcome",
    to: [{nil, subscriber.email}]
  )
end
```

### Testing Token Expiration

```elixir
test "rejects expired token" do
  # Create subscriber with expired token
  expired_at = DateTime.add(DateTime.utc_now(), -3600, :second)
  subscriber = subscriber_fixture(%{
    verification_token: "token",
    verification_token_expires_at: expired_at
  })

  # Attempt verification
  assert {:error, :invalid_or_expired_token} =
    Newsletter.verify_subscriber("token")
end
```

### Testing LiveView Forms

```elixir
test "submits form successfully", %{conn: conn} do
  {:ok, view, _html} = live(conn, ~p"/path")

  view
  |> form("#form-id", %{field: "value"})
  |> render_submit()

  assert render(view) =~ "Success message"
end
```

---

## Troubleshooting

### Test Database Issues

```bash
# Reset test database
MIX_ENV=test mix ecto.reset

# Check database connection
MIX_ENV=test mix ecto.migrate --migrations-path priv/repo/migrations
```

### Async Test Conflicts

If tests fail randomly in async mode:
- Check for shared global state
- Verify database isolation
- Use `async: false` for problematic tests

### Slow Tests

```bash
# Identify slow tests
mix test --slowest

# Profile test execution
mix test --trace
```

### Email Assertions Failing

```elixir
# Verify Swoosh test adapter configured
# config/test.exs should have:
config :strive_planner, StrivePlanner.Mailer,
  adapter: Swoosh.Adapters.Test
```

---

## Next Steps

After completing test coverage:

1. ✅ Run full test suite: `mix test`
2. ✅ Check coverage: `mix test --cover`
3. ✅ Verify all tests pass: Target 90%+ coverage
4. ✅ Update documentation: Add TDD examples to README
5. ✅ Create PR: Submit for review with coverage report

---

## Resources

- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Phoenix Testing Guide](https://hexdocs.pm/phoenix/testing.html)
- [Phoenix LiveView Testing](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
- [Swoosh Testing](https://hexdocs.pm/swoosh/Swoosh.TestAssertions.html)

---

## Summary

This quickstart provides:

1. ✅ **Setup instructions** for test environment
2. ✅ **Implementation order** (fixtures → contexts → controllers → LiveViews)
3. ✅ **Code examples** for each test type
4. ✅ **TDD workflow** for future development
5. ✅ **Common patterns** for typical scenarios
6. ✅ **Troubleshooting guide** for common issues

Follow this guide to implement comprehensive test coverage efficiently and establish TDD practices for future development.
