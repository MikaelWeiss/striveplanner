# Data Model: Test-Driven Development Implementation

**Feature**: 001-tdd-coverage
**Date**: 2025-10-23
**Status**: Complete

## Overview

This feature does not introduce new data entities. Instead, it creates tests that validate existing data models and their business logic. This document describes the test data entities (fixtures) that will be used across the test suite.

## Test Fixtures (Test Data Entities)

### Newsletter Fixtures

**Purpose**: Create reusable test data for newsletter subscription testing

**Entities**:

#### Subscriber (Test Data)
- **email**: String - unique test email (e.g., `test-123@example.com`)
- **verified**: Boolean - subscription verification status (default: false)
- **verification_token**: String (optional) - token for email verification
- **verification_token_expires_at**: DateTime (optional) - token expiration timestamp

**States**:
- Unverified subscriber (default)
- Verified subscriber
- Subscriber with valid verification token
- Subscriber with expired verification token

**Fixture Functions**:
```elixir
# test/support/fixtures/newsletter_fixtures.ex
subscriber_fixture(attrs \\ %{})        # Creates unverified subscriber
verified_subscriber_fixture(attrs \\ %{})  # Creates verified subscriber
subscriber_with_token_fixture(attrs \\ %{})  # Creates subscriber with verification token
```

---

### Accounts Fixtures

**Purpose**: Create reusable test data for user and admin authentication testing

**Entities**:

#### User (Test Data)
- **email**: String - unique test email
- **role**: String - user role ("user" or "admin")
- **magic_link_token**: String (optional) - magic link authentication token
- **magic_link_expires_at**: DateTime (optional) - token expiration timestamp

**States**:
- Regular user (role: "user")
- Admin user (role: "admin")
- Admin with valid magic link token
- Admin with expired magic link token

**Fixture Functions**:
```elixir
# test/support/fixtures/accounts_fixtures.ex
user_fixture(attrs \\ %{})              # Creates regular user
admin_fixture(attrs \\ %{})             # Creates admin user
admin_with_magic_link_fixture(attrs \\ %{})  # Creates admin with valid magic link
```

---

### Blog Fixtures

**Purpose**: Create reusable test data for blog post and comment testing

**Entities**:

#### BlogPost (Test Data)
- **title**: String - blog post title
- **slug**: String - URL-friendly identifier
- **content**: String - markdown content
- **status**: String - publication status ("draft" or "published")
- **published_at**: DateTime (optional) - publication timestamp
- **view_count**: Integer - number of views (default: 0)
- **email_sent_at**: DateTime (optional) - when post was sent to subscribers
- **email_recipient_count**: Integer (optional) - number of recipients
- **sent_to_subscribers**: Boolean - whether post was sent (default: false)

**States**:
- Draft blog post (not published)
- Published blog post
- Published blog post with views
- Blog post sent to subscribers

**Fixture Functions**:
```elixir
# test/support/fixtures/blog_fixtures.ex
blog_post_fixture(attrs \\ %{})         # Creates draft blog post
published_post_fixture(attrs \\ %{})    # Creates published blog post
post_with_views_fixture(attrs \\ %{})   # Creates post with view count
sent_post_fixture(attrs \\ %{})         # Creates post sent to subscribers
```

#### Comment (Test Data)
- **content**: String - comment content
- **blog_post_id**: Integer - associated blog post
- **status**: String - moderation status

**Fixture Functions**:
```elixir
comment_fixture(blog_post, attrs \\ %{})  # Creates comment for blog post
```

---

## Test Isolation Model

### Database Transaction Boundaries

Each test runs in an isolated database transaction:

```
Test Execution:
┌─────────────────────────────────────┐
│ Test Start                          │
│   ↓                                 │
│ BEGIN TRANSACTION (automatic)       │
│   ↓                                 │
│ Create test data via fixtures      │
│   ↓                                 │
│ Execute test assertions            │
│   ↓                                 │
│ ROLLBACK (automatic)                │
│   ↓                                 │
│ Test End (database clean)          │
└─────────────────────────────────────┘
```

### Async vs Sync Tests

**Async Tests** (`async: true`):
- Run in parallel with other tests
- Each gets its own database connection
- Faster test execution
- Most tests should be async

**Sync Tests** (default):
- Run sequentially
- Share a database connection pool
- Required for tests that share global state (rare in our case)

---

## Mock Data Patterns

### Email Testing Data

**Pattern**: Swoosh.TestAssertions with test adapter

```elixir
# config/test.exs
config :strive_planner, StrivePlanner.Mailer,
  adapter: Swoosh.Adapters.Test

# In tests:
import Swoosh.TestAssertions

test "sends welcome email" do
  # Execute code that sends email

  # Verify email was sent
  assert_email_sent(
    subject: "Welcome to StrivePlanner",
    to: [{"Test User", "test@example.com"}]
  )
end
```

### Time-Based Testing Data

**Pattern**: Fixed DateTime values for token expiration

```elixir
# Valid token (not expired)
valid_token_timestamp = DateTime.add(DateTime.utc_now(), 3600, :second)  # 1 hour from now

# Expired token
expired_token_timestamp = DateTime.add(DateTime.utc_now(), -3600, :second)  # 1 hour ago

# Use in fixtures
subscriber_fixture(%{
  verification_token: "test-token",
  verification_token_expires_at: expired_token_timestamp
})
```

---

## Validation Rules (Tested)

These validation rules exist in the application and will be tested:

### Newsletter Subscriber Validations
- Email must be present
- Email must be valid format
- Email must be unique (case-insensitive)
- Verification token must be unique if present

### User Validations
- Email must be present
- Email must be valid format
- Email must be unique (case-insensitive)
- Role must be "user" or "admin"
- Magic link token must be unique if present

### Blog Post Validations
- Title must be present
- Slug must be present and unique
- Content must be present
- Status must be "draft" or "published"
- Published_at required if status is "published"

---

## Relationships (Tested)

### Blog Post → Comments
- One blog post has many comments
- Deleting a blog post should handle associated comments (tested)

### Newsletter → Subscribers (conceptual)
- Blog posts can be sent to verified subscribers
- Test sending logic validates relationship between posts and subscribers

---

## State Transitions (Tested)

### Newsletter Subscription Flow
```
Unverified → Generate Token → Send Email → Verify Token → Verified
                    ↓
              Token Expires → Error State
```

### Admin Authentication Flow
```
Request Login → Generate Magic Link → Send Email → Verify Token → Authenticated
                        ↓
                  Token Expires → Error State
                        ↓
                  Clear Token → Ready for New Login
```

### Blog Post Publishing Flow
```
Draft → Publish → Published → Send to Subscribers → Sent
          ↓
    Set published_at, status="published"
                                    ↓
                          Track recipient count, email_sent_at
```

---

## Test Data Lifecycle

### Creation Pattern
```elixir
# In test
setup do
  subscriber = subscriber_fixture()
  admin = admin_fixture()
  post = published_post_fixture()

  %{subscriber: subscriber, admin: admin, post: post}
end

test "uses fixture data", %{subscriber: subscriber, admin: admin, post: post} do
  # Test with pre-created data
end
```

### Cleanup Pattern
- Automatic via database rollback
- No manual cleanup needed
- Each test starts with empty database

---

## Performance Considerations

### Fixture Efficiency
- Fixtures insert minimal required data
- Avoid creating unnecessary associations
- Use bare minimum fields for test scenario

**Good**:
```elixir
subscriber_fixture(%{email: "specific@test.com"})  # Only override what's needed
```

**Avoid**:
```elixir
# Don't create unused related data
subscriber_with_posts_and_comments_fixture()  # Unless actually testing relationships
```

### Parallel Test Execution
- Each async test gets isolated data
- No fixture sharing between tests
- Database connection pool sized appropriately

---

## Summary

This data model document describes:

1. ✅ **Test Fixtures**: Reusable test data creation patterns for Newsletter, Accounts, and Blog
2. ✅ **Isolation Model**: Database transaction boundaries and async/sync patterns
3. ✅ **Mock Patterns**: Email testing and time-based testing approaches
4. ✅ **Validation Rules**: What business rules will be tested
5. ✅ **State Transitions**: Workflows that tests will validate
6. ✅ **Lifecycle**: How test data is created and cleaned up

**No new database entities** - This feature only creates test infrastructure for validating existing entities.
