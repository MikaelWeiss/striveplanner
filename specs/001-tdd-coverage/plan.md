# Implementation Plan: Test-Driven Development Implementation

**Branch**: `001-tdd-coverage` | **Date**: 2025-10-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-tdd-coverage/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature implements comprehensive test coverage for the StrivePlanner application using test-driven development practices. The implementation focuses on creating tests for existing functionality across Newsletter, Accounts, and Blog contexts, along with controller, API, and LiveView integration tests. The goal is to achieve 90%+ test coverage, enable confident refactoring, and establish TDD patterns for future development.

## Technical Context

**Language/Version**: Elixir 1.15+
**Primary Dependencies**: Phoenix 1.8.0, Ecto 3.13, ExUnit (built-in), Phoenix.LiveViewTest
**Storage**: PostgreSQL (test database using Ecto.Adapters.SQL.Sandbox)
**Testing**: ExUnit, Phoenix.ConnCase, Phoenix.DataCase, Phoenix.LiveViewTest
**Target Platform**: Web server (development and CI environments)
**Project Type**: Web application (Phoenix)
**Performance Goals**: Test suite completes in under 10 seconds for rapid feedback
**Constraints**: Tests must be isolated (no shared state), no external dependencies (mocked email)
**Scale/Scope**: 3 contexts (Newsletter, Accounts, Blog), ~15 test files, 90%+ coverage target

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The following checks ensure alignment with the StrivePlanner Constitution (v2.0.0):

### Principle I: User Empowerment First
- [x] Feature reduces friction and eliminates confusion in user flows - *Tests prevent bugs that would confuse users*
- [N/A] Language and UI elements are encouraging and motivating - *No UI changes*
- [N/A] Feature helps users define goals and provides actionable paths - *Infrastructure feature*
- [x] Content provides tangible value toward goal achievement - *Reliable software empowers users*

### Principle II: Jony Ive Design Philosophy
- [N/A] Design feels inevitable and fades into background - *No UI changes*
- [N/A] Whitespace is generous (2-3x standard spacing minimum) - *No UI changes*
- [N/A] Interactive elements use soft rounded corners (12px+ border-radius) - *No UI changes*
- [N/A] Color palette is calming (earth tones, soft blues, warm neutrals) - *No UI changes*
- [N/A] Interactions are intuitive without requiring instructions - *No UI changes*
- [N/A] Visual hierarchy through typography/spacing, not color/decoration - *No UI changes*
- [N/A] Every element justifies its existence - *No UI changes*

### Principle III: Test-First Development
- [x] Tests will be written before implementation - *This IS the test implementation*
- [x] TDD Red-Green-Refactor cycle planned - *Tests for existing code follow adapted TDD approach*
- [x] Test categories identified (context tests, LiveView tests, etc.) - *All categories defined in spec*

### Principle IV: Phoenix Conventions & Contexts
- [x] Phoenix Contexts define clear domain boundaries - *Tests validate context boundaries*
- [x] Each context exposes well-defined public API - *Tests verify public API contracts*
- [x] Contexts do not call other contexts' private functions - *Tests will catch violations*
- [x] Business logic resides in contexts, not controllers/LiveViews - *Context tests separate from integration tests*
- [x] Follows `lib/strive_planner/` (business) and `lib/strive_planner_web/` (web) separation - *Test structure mirrors source structure*
- [x] Ecto schemas live within their respective contexts - *Existing architecture validated by tests*
- [x] Database queries composed in context modules using Ecto.Query - *Tests verify query composition*
- [x] Changesets created in schema/context modules, not controllers/LiveViews - *Tests verify changeset usage*

### Principle V: Content-Driven Experience
- [N/A] Blog posts are concise and focused on one principle - *No content changes*
- [N/A] Content has clear, achievable promise - *No content changes*
- [N/A] Tone is encouraging and motivating - *No content changes*
- [N/A] Community interactions facilitate meaningful support - *No content changes*

**Gate Status**: ✅ PASSED - All applicable principles satisfied. This is a pure infrastructure feature focused on test coverage and quality assurance.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Test Files to Create (NEW)
test/strive_planner/
├── newsletter_test.exs           # Newsletter context tests (NEW)
├── accounts_test.exs             # Accounts context tests (NEW)
└── blog_test.exs                 # Blog context tests (NEW)

test/strive_planner_web/
├── controllers/
│   ├── page_controller_test.exs  # EXISTS - expand coverage
│   └── api/
│       └── newsletter_controller_test.exs  # API endpoint tests (NEW)
└── live/
    └── admin/
        ├── login_live_test.exs   # Admin login flow tests (NEW)
        └── dashboard_live_test.exs  # Admin dashboard tests (NEW)

test/support/
├── fixtures/
│   ├── newsletter_fixtures.ex    # Newsletter test data helpers (NEW)
│   ├── accounts_fixtures.ex      # Accounts test data helpers (NEW)
│   └── blog_fixtures.ex          # Blog test data helpers (NEW)
├── conn_case.ex                  # EXISTS - may enhance
└── data_case.ex                  # EXISTS - may enhance

# Existing Source Code (NO CHANGES - tests validate these)
lib/strive_planner/
├── newsletter.ex                 # Newsletter context - TESTED
├── accounts.ex                   # Accounts context - TESTED
├── blog.ex                       # Blog context - TESTED
├── newsletter/
│   └── subscriber.ex             # Schema - TESTED via context
├── accounts/
│   └── user.ex                   # Schema - TESTED via context
└── blog/
    ├── blog_post.ex              # Schema - TESTED via context
    └── comment.ex                # Schema - TESTED via context

lib/strive_planner_web/
├── controllers/
│   ├── page_controller.ex        # TESTED
│   ├── admin_controller.ex       # TESTED
│   └── api/
│       └── newsletter_controller.ex  # TESTED
├── live/
│   └── admin/
│       ├── login_live.ex         # TESTED
│       └── dashboard_live.ex     # TESTED
├── plugs/
│   └── require_admin.ex          # TESTED (via integration tests)
└── router.ex                     # TESTED (via controller/LiveView tests)
```

**Structure Decision**: This feature creates tests for three existing Phoenix contexts:
- **StrivePlanner.Newsletter**: Manages newsletter subscriptions and verification
- **StrivePlanner.Accounts**: Manages users and admin authentication
- **StrivePlanner.Blog**: Manages blog posts and comments

Tests will be organized following Phoenix conventions:
- Context tests in `test/strive_planner/` for business logic
- Controller tests in `test/strive_planner_web/controllers/` for HTTP endpoints
- LiveView tests in `test/strive_planner_web/live/` for interactive UI
- Fixture helpers in `test/support/fixtures/` for reusable test data

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations** - All constitution principles are satisfied.

---

## Phase 0: Research (Complete)

**Status**: ✅ Complete

**Output**: [research.md](./research.md)

**Key Decisions**:
- Use ExUnit (built-in Elixir testing framework)
- Use Ecto.Adapters.SQL.Sandbox for test isolation
- Use Swoosh.TestAssertions for email testing
- Use Phoenix fixture pattern for test data
- Follow Phoenix test structure conventions
- Parallelize tests with `async: true` for speed

**No NEEDS CLARIFICATION items** - All decisions based on established Phoenix/Elixir patterns.

---

## Phase 1: Design & Contracts (Complete)

**Status**: ✅ Complete

**Outputs**:
- [data-model.md](./data-model.md) - Test fixtures and data patterns
- [contracts/test-contracts.md](./contracts/test-contracts.md) - Test coverage contracts
- [quickstart.md](./quickstart.md) - Implementation guide

**Key Artifacts**:

### Test Fixtures Defined
- Newsletter fixtures (subscriber, verified subscriber, subscriber with token)
- Accounts fixtures (user, admin, admin with magic link)
- Blog fixtures (draft post, published post, post with views, comments)

### Test Contracts Established
- Newsletter context: 5 function groups, 15+ test cases
- Accounts context: 6 function groups, 17+ test cases
- Blog context: 9 function groups, 25+ test cases
- Controller tests: Page controller, Newsletter API
- LiveView tests: Admin login, Admin dashboard

### Implementation Guide Created
- Phase-by-phase implementation order
- Code examples for each test type
- TDD workflow documentation
- Common patterns and troubleshooting

**Agent Context Updated**: ✅ Claude Code context file updated with testing stack

---

## Next Steps

**Ready for**: `/speckit.tasks` command

The planning phase is complete. The next command will generate the task breakdown (`tasks.md`) based on this implementation plan.

**What to expect**:
- Tasks organized by priority (P1-P4)
- Dependency-ordered task list
- Specific implementation steps
- Acceptance criteria for each task

**Recommended workflow**:
1. Run `/speckit.tasks` to generate task breakdown
2. Review tasks for completeness
3. Begin implementation following quickstart guide
4. Run `/speckit.implement` to execute tasks (or implement manually)

---

## Planning Summary

| Aspect | Status | Details |
|--------|--------|---------|
| Constitution Check | ✅ Passed | All applicable principles satisfied |
| Technical Context | ✅ Complete | Elixir 1.15+, Phoenix 1.8, ExUnit, PostgreSQL |
| Research | ✅ Complete | All tooling decisions made |
| Data Model | ✅ Complete | Test fixtures defined |
| Contracts | ✅ Complete | Test coverage contracts established |
| Quickstart | ✅ Complete | Implementation guide ready |
| Agent Context | ✅ Updated | Claude Code context file updated |

**Feature**: Ready for task generation and implementation
