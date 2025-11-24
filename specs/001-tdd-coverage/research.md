# Research: Test-Driven Development Implementation

**Feature**: 001-tdd-coverage
**Date**: 2025-10-23
**Status**: Complete

## Overview

This document consolidates research findings for implementing comprehensive test coverage for the StrivePlanner Phoenix application. Since all technical decisions are already made (using Phoenix's built-in testing tools), this research focuses on best practices and patterns.

## Testing Framework & Tools

### Decision: ExUnit with Phoenix Test Helpers

**Rationale**:
- ExUnit is Elixir's built-in testing framework - no additional dependencies
- Phoenix provides specialized test helpers via `Phoenix.ConnCase` and `Phoenix.DataCase`
- Phoenix.LiveViewTest provides first-class support for testing LiveView interactions
- Ecto.Adapters.SQL.Sandbox provides automatic test isolation

**Alternatives Considered**:
- Third-party testing frameworks (Wallaby for integration): Rejected because ExUnit + LiveViewTest cover our needs
- Property-based testing (StreamData): Out of scope for this feature, but can be added later
- External testing services: Not needed for unit/integration tests

**Best Practices**:
- Use `async: true` for tests that don't share database state to parallelize execution
- Use `Phoenix.ConnCase` for controller tests (provides `conn` fixture)
- Use `Phoenix.DataCase` for context tests (provides database sandbox)
- Use `Phoenix.LiveViewTest` for LiveView tests (provides `live` helpers)

## Test Isolation Strategy

### Decision: Ecto.Adapters.SQL.Sandbox

**Rationale**:
- Automatically wraps each test in a database transaction
- Tests are completely isolated - no shared state between tests
- Rollback happens automatically after each test
- No need to manually clean up test data
- Already configured in Phoenix applications by default

**Alternatives Considered**:
- Manual database cleanup: Rejected - error-prone and slower
- Shared fixtures: Rejected - leads to test coupling and flakiness
- In-memory database: Rejected - want to test against real PostgreSQL

**Best Practices**:
- Each test creates its own data using fixture helpers
- Tests should not depend on execution order
- Use `Ecto.Adapters.SQL.Sandbox.mode(repo, :manual)` for async tests

## Mocking External Dependencies

### Decision: Swoosh.TestAssertions for Email Testing

**Rationale**:
- Swoosh is already used in the application for email sending
- `Swoosh.TestAssertions` provides helpers to verify emails were sent without actually sending them
- No need for additional mocking libraries
- Tests can verify email content, recipients, and delivery

**Alternatives Considered**:
- Mox/Hammox for mocking: Overkill for email testing, Swoosh has built-in test support
- Actually sending emails in tests: Rejected - slow, unreliable, requires external services
- Custom email spy: Rejected - reinventing the wheel

**Best Practices**:
- Configure Swoosh to use `Swoosh.Adapters.Test` in test environment
- Use `assert_email_sent/1` and `assert_no_email_sent/0` from Swoosh.TestAssertions
- Verify email content, not just that an email was sent

## Time-Sensitive Testing

### Decision: Manual Time Stubbing with DateTime

**Rationale**:
- Token expiration tests need to verify time-based logic
- Elixir's DateTime module can be used with test-specific timestamps
- Can pass specific DateTime values to functions instead of relying on `DateTime.utc_now()`
- Simpler than introducing a mocking library for this single use case

**Alternatives Considered**:
- Mox for mocking DateTime: Rejected - too heavy for our limited time-testing needs
- Waiting for real time to pass: Rejected - tests would be slow and unreliable
- Time travel library: Rejected - no mature Elixir time-mocking library widely adopted

**Best Practices**:
- Create helper functions that accept optional `now` parameter for testing
- Default to `DateTime.utc_now()` in production, pass fixed time in tests
- Test both valid and expired token scenarios

## Test Data Management

### Decision: Phoenix Fixtures Pattern

**Rationale**:
- Phoenix convention for creating reusable test data
- Keeps test data creation DRY
- Easy to override defaults for specific test scenarios
- Located in `test/support/fixtures/` directory

**Alternatives Considered**:
- Factory libraries (ExMachina): Rejected - adds dependency for functionality we can implement simply
- Inline test data: Rejected - leads to duplication and verbose tests
- Shared database fixtures: Rejected - violates test isolation

**Best Practices**:
- Create one fixture module per context (`newsletter_fixtures.ex`, `accounts_fixtures.ex`, etc.)
- Provide functions like `subscriber_fixture(attrs \\ %{})` that accept attribute overrides
- Insert data into database in fixtures (not just return structs)
- Use sensible defaults for all required fields

**Example Pattern**:
```elixir
# test/support/fixtures/newsletter_fixtures.ex
defmodule StrivePlanner.NewsletterFixtures do
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

## Test Organization

### Decision: Follow Phoenix Test Structure

**Rationale**:
- Phoenix has established conventions for test organization
- Mirrors the source code structure
- Clear separation between business logic tests and integration tests
- Easy to locate tests for specific modules

**Structure**:
```
test/
├── strive_planner/          # Context tests (business logic)
│   ├── newsletter_test.exs
│   ├── accounts_test.exs
│   └── blog_test.exs
├── strive_planner_web/      # Integration tests
│   ├── controllers/
│   │   ├── page_controller_test.exs
│   │   └── api/
│   │       └── newsletter_controller_test.exs
│   └── live/
│       └── admin/
│           ├── login_live_test.exs
│           └── dashboard_live_test.exs
└── support/                 # Test helpers
    ├── fixtures/
    │   ├── newsletter_fixtures.ex
    │   ├── accounts_fixtures.ex
    │   └── blog_fixtures.ex
    ├── conn_case.ex
    └── data_case.ex
```

## Coverage Measurement

### Decision: Built-in ExUnit Coverage

**Rationale**:
- ExUnit has built-in coverage via `mix test --cover`
- Generates coverage reports without additional dependencies
- Sufficient for tracking progress toward 90% coverage goal

**Alternatives Considered**:
- Coveralls: Rejected - adds dependency, not needed for local development
- Codecov: Rejected - CI/CD integration out of scope for this feature

**Best Practices**:
- Run `mix test --cover` to check coverage
- Focus on coverage of public APIs in contexts
- 100% coverage is not the goal - 90% is sufficient, some error paths may be hard to test

## Test Naming Conventions

### Decision: Phoenix/ExUnit Conventions

**Best Practices**:
- Test file names match source file names with `_test` suffix
- Use descriptive test names: `test "creates subscriber with valid email"`
- Group related tests with `describe` blocks
- Use `setup` for common test setup within a describe block

**Example**:
```elixir
defmodule StrivePlanner.NewsletterTest do
  use StrivePlanner.DataCase

  describe "create_subscriber/1" do
    test "creates subscriber with valid email" do
      # test implementation
    end

    test "returns error with invalid email" do
      # test implementation
    end

    test "returns error with duplicate email" do
      # test implementation
    end
  end
end
```

## Performance Considerations

### Decision: Parallelize Tests Where Possible

**Rationale**:
- ExUnit can run tests in parallel to speed up execution
- Goal is sub-10-second test suite
- Most tests can be parallelized with proper isolation

**Best Practices**:
- Use `async: true` for tests that are database-isolated
- Avoid `async: true` for tests that share resources (e.g., file system)
- Monitor test suite execution time
- Profile slow tests with `mix test --slowest`

## Documentation Strategy

### Decision: Inline Documentation + TDD Examples

**Rationale**:
- Tests serve as living documentation of how code should be used
- Add module-level `@moduledoc` to test files explaining what's being tested
- Include TDD workflow examples in project README

**Best Practices**:
- Each test should be self-documenting through clear names and arrange-act-assert structure
- Include comments only for complex setup or non-obvious assertions
- Document TDD workflow in README for future contributors

## Summary

All technical decisions for this feature align with Phoenix/Elixir ecosystem best practices:

1. ✅ Use ExUnit (built-in, no additional dependencies)
2. ✅ Use Ecto.Adapters.SQL.Sandbox for test isolation
3. ✅ Use Swoosh.TestAssertions for email testing
4. ✅ Use Phoenix fixture pattern for test data
5. ✅ Follow Phoenix test structure conventions
6. ✅ Parallelize tests for speed
7. ✅ Use built-in coverage tooling

**No NEEDS CLARIFICATION items remain** - all decisions are based on established Phoenix patterns.
