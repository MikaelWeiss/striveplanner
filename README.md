# StrivePlanner

A productivity and goal-setting application built with Phoenix and Elixir.

## Getting Started

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Testing

This project follows test-driven development (TDD) practices with comprehensive test coverage.

### Running Tests

```bash
# Run all tests
mix test

# Run tests with coverage report
mix test --cover

# Run specific test file
mix test test/strive_planner/newsletter_test.exs

# Run only failed tests
mix test --failed

# Run tests and show slowest tests
mix test --slowest
```

### Test Organization

Tests are organized following Phoenix conventions:

- `test/strive_planner/` - Business logic tests (contexts)
- `test/strive_planner_web/` - Integration tests (controllers, LiveViews)
- `test/support/fixtures/` - Test data helpers

### TDD Workflow

For detailed TDD workflow guidance, see [specs/001-tdd-coverage/quickstart.md](specs/001-tdd-coverage/quickstart.md).

**Quick TDD cycle**:

1. **Red**: Write a failing test for the new feature
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code while keeping tests green

### Test Fixtures

Create test data using fixture helpers:

```elixir
# In your test file
import StrivePlanner.NewsletterFixtures

test "example test" do
  subscriber = subscriber_fixture()
  # Test with the subscriber...
end
```

Available fixtures:
- `NewsletterFixtures` - subscriber, verified_subscriber, subscriber_with_token
- `AccountsFixtures` - user, admin, admin_with_magic_link
- `BlogFixtures` - blog_post, published_post, post_with_views, comment

### Coverage Goals

- Target: 90%+ coverage for context modules
- Current status: Run `mix test --cover` to view current coverage

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
