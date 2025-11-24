# Test Contracts: TDD Implementation

**Feature**: 001-tdd-coverage
**Date**: 2025-10-23

## Overview

This document defines the "contracts" for test coverage - the expected test interfaces and validation patterns for each module. These contracts ensure consistency across the test suite.

---

## Context Test Contracts

### Newsletter Context Contract

**Module**: `StrivePlanner.Newsletter`
**Test File**: `test/strive_planner/newsletter_test.exs`

**Required Test Coverage**:

```elixir
describe "create_subscriber/1" do
  test "creates subscriber with valid attributes"
  test "returns error with invalid email"
  test "returns error with duplicate email"
  test "generates unique email field"
end

describe "get_subscriber_by_email/1" do
  test "returns subscriber when email exists"
  test "returns nil when email does not exist"
  test "is case-insensitive"
end

describe "email_subscribed?/1" do
  test "returns true when email exists"
  test "returns false when email does not exist"
end

describe "generate_verification_token/1" do
  test "generates unique token"
  test "sets expiration 24 hours in future"
  test "returns error for invalid subscriber"
end

describe "verify_subscriber/1" do
  test "verifies subscriber with valid token"
  test "returns error with expired token"
  test "returns error with invalid token"
  test "returns error for already verified subscriber"
  test "marks subscriber as verified"
end
```

---

### Accounts Context Contract

**Module**: `StrivePlanner.Accounts`
**Test File**: `test/strive_planner/accounts_test.exs`

**Required Test Coverage**:

```elixir
describe "get_user_by_email/1" do
  test "returns user when email exists"
  test "returns nil when email does not exist"
end

describe "get_user/1" do
  test "returns user when ID exists"
  test "returns nil when ID does not exist"
end

describe "create_user/1" do
  test "creates user with valid attributes"
  test "returns error with invalid email"
  test "returns error with duplicate email"
  test "defaults role to 'user'"
end

describe "admin?/1" do
  test "returns true for admin user"
  test "returns false for regular user"
end

describe "generate_admin_magic_link/1" do
  test "generates token for admin user"
  test "returns error for non-existent user"
  test "returns error for non-admin user"
  test "sets expiration 15 minutes in future"
  test "generates unique token"
end

describe "verify_admin_magic_link/1" do
  test "verifies admin with valid token"
  test "returns error with expired token"
  test "returns error with invalid token"
  test "clears token after successful verification"
  test "returns error for non-admin user"
end
```

---

### Blog Context Contract

**Module**: `StrivePlanner.Blog`
**Test File**: `test/strive_planner/blog_test.exs`

**Required Test Coverage**:

```elixir
describe "list_posts/0" do
  test "returns all published posts"
  test "does not return draft posts"
  test "orders by published_at desc"
  test "returns empty list when no posts"
end

describe "list_all_posts/0" do
  test "returns all posts including drafts"
  test "orders by updated_at desc"
end

describe "get_post/1" do
  test "returns published post by slug"
  test "returns error for draft post"
  test "returns error for non-existent slug"
end

describe "get_post!/1" do
  test "returns post by ID"
  test "raises for non-existent ID"
end

describe "create_post/1" do
  test "creates post with valid attributes"
  test "returns error with invalid attributes"
  test "generates unique slug from title"
end

describe "update_post/2" do
  test "updates post with valid attributes"
  test "returns error with invalid attributes"
end

describe "delete_post/1" do
  test "deletes the post"
  test "returns error for non-existent post"
end

describe "increment_view_count/1" do
  test "increments view count by 1"
  test "handles multiple increments"
end

describe "render_markdown/1" do
  test "converts markdown to HTML"
  test "returns empty string for nil"
  test "returns original content on parse error"
end

describe "send_to_subscribers/1" do
  test "sends email to all verified subscribers"
  test "returns count of emails sent"
  test "updates post with sent metadata"
  test "returns error when no subscribers"
end
```

---

## Controller Test Contracts

### Page Controller Contract

**Module**: `StrivePlannerWeb.PageController`
**Test File**: `test/strive_planner_web/controllers/page_controller_test.exs`

**Required Test Coverage**:

```elixir
describe "GET /" do
  test "renders home page"
  test "returns 200 status"
end

describe "GET /about" do
  test "renders about page"
  test "returns 200 status"
end

describe "GET /blog" do
  test "lists all published posts"
  test "does not show draft posts"
end

describe "GET /blog/:slug" do
  test "shows published blog post"
  test "increments view count"
  test "renders markdown content"
  test "returns 404 for draft post"
  test "returns 404 for non-existent post"
end

describe "GET /newsletter/verify/:token" do
  test "verifies subscriber with valid token"
  test "redirects to welcome page"
  test "returns error for invalid token"
  test "returns error for expired token"
end

describe "GET /newsletter/welcome" do
  test "renders welcome page"
end
```

---

### Newsletter API Controller Contract

**Module**: `StrivePlannerWeb.API.NewsletterController`
**Test File**: `test/strive_planner_web/controllers/api/newsletter_controller_test.exs`

**Required Test Coverage**:

```elixir
describe "POST /api/newsletter/subscribe" do
  test "creates subscriber and sends verification email"
  test "returns success JSON"
  test "returns error for invalid email"
  test "returns error for duplicate subscription"
  test "sends verification email with token"
end
```

---

## LiveView Test Contracts

### Admin Login LiveView Contract

**Module**: `StrivePlannerWeb.Admin.LoginLive`
**Test File**: `test/strive_planner_web/live/admin/login_live_test.exs`

**Required Test Coverage**:

```elixir
describe "mount" do
  test "renders login form"
  test "shows email input"
end

describe "handle_event submit" do
  test "sends magic link to admin user"
  test "shows success message"
  test "returns error for non-existent user"
  test "returns error for non-admin user"
  test "sends email with magic link"
end
```

---

### Admin Dashboard LiveView Contract

**Module**: `StrivePlannerWeb.Admin.DashboardLive`
**Test File**: `test/strive_planner_web/live/admin/dashboard_live_test.exs`

**Required Test Coverage**:

```elixir
describe "mount with authenticated admin" do
  test "renders dashboard"
  test "shows admin content"
end

describe "mount without authentication" do
  test "redirects to login"
end
```

---

## Test Helper Contracts

### Newsletter Fixtures

**Module**: `StrivePlanner.NewsletterFixtures`
**File**: `test/support/fixtures/newsletter_fixtures.ex`

**Required Functions**:

```elixir
@spec subscriber_fixture(map()) :: StrivePlanner.Newsletter.Subscriber.t()
# Creates unverified subscriber with unique email

@spec verified_subscriber_fixture(map()) :: StrivePlanner.Newsletter.Subscriber.t()
# Creates verified subscriber

@spec subscriber_with_token_fixture(map()) :: StrivePlanner.Newsletter.Subscriber.t()
# Creates subscriber with valid verification token
```

---

### Accounts Fixtures

**Module**: `StrivePlanner.AccountsFixtures`
**File**: `test/support/fixtures/accounts_fixtures.ex`

**Required Functions**:

```elixir
@spec user_fixture(map()) :: StrivePlanner.Accounts.User.t()
# Creates regular user

@spec admin_fixture(map()) :: StrivePlanner.Accounts.User.t()
# Creates admin user

@spec admin_with_magic_link_fixture(map()) :: StrivePlanner.Accounts.User.t()
# Creates admin with valid magic link token
```

---

### Blog Fixtures

**Module**: `StrivePlanner.BlogFixtures`
**File**: `test/support/fixtures/blog_fixtures.ex`

**Required Functions**:

```elixir
@spec blog_post_fixture(map()) :: StrivePlanner.Blog.BlogPost.t()
# Creates draft blog post

@spec published_post_fixture(map()) :: StrivePlanner.Blog.BlogPost.t()
# Creates published blog post

@spec post_with_views_fixture(map()) :: StrivePlanner.Blog.BlogPost.t()
# Creates published post with view count

@spec comment_fixture(StrivePlanner.Blog.BlogPost.t(), map()) :: StrivePlanner.Blog.Comment.t()
# Creates comment for blog post
```

---

## Assertion Patterns

### Standard Assertions

```elixir
# Success cases
assert {:ok, %Struct{}} = function_call()
assert result == expected_value
assert Enum.member?(list, item)

# Error cases
assert {:error, %Ecto.Changeset{}} = function_call()
assert {:error, :atom_reason} = function_call()
refute condition

# Pattern matching
assert %Struct{field: value} = result
```

### Email Assertions

```elixir
import Swoosh.TestAssertions

assert_email_sent(
  subject: "Expected Subject",
  to: [{"Name", "email@example.com"}]
)

assert_no_email_sent()
```

### LiveView Assertions

```elixir
{:ok, view, html} = live(conn, "/path")

assert html =~ "Expected Content"
assert has_element?(view, "#element-id")
assert render(view) =~ "Content"

# Form submission
assert view
       |> form("#form-id", form_data)
       |> render_submit() =~ "Success"
```

---

## Performance Contracts

### Test Execution Time

**Contract**: Total test suite MUST complete in under 10 seconds

**Monitoring**:
```bash
mix test --slowest
```

**Optimization Strategies**:
- Use `async: true` for isolated tests
- Minimize database operations per test
- Use efficient fixture creation
- Parallelize test execution

---

## Coverage Contracts

### Minimum Coverage Requirements

**Contract**: 90% coverage for all context modules

**Measurement**:
```bash
mix test --cover
```

**Exclusions**:
- Generated Phoenix boilerplate (if any)
- Error handling for impossible states (optional)
- Private helper functions (test via public API)

---

## Summary

This contracts document defines:

1. ✅ **Test structure** for all context modules
2. ✅ **Required test coverage** for each function
3. ✅ **Fixture interfaces** for test data creation
4. ✅ **Assertion patterns** for consistency
5. ✅ **Performance contracts** for test execution
6. ✅ **Coverage requirements** for quality assurance

All tests must adhere to these contracts to ensure comprehensive and consistent test coverage.
