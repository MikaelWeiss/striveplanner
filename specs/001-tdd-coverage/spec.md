# Feature Specification: Test-Driven Development Implementation

**Feature Branch**: `001-tdd-coverage`
**Created**: 2025-10-23
**Status**: Draft
**Input**: User description: "Update this project to better use test driven development and have tests for what's currently there."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Core Business Logic Validation (Priority: P1)

As a developer maintaining the application, I need comprehensive tests for critical business logic so that I can confidently make changes without breaking existing functionality, particularly around newsletter subscriptions and admin authentication flows.

**Why this priority**: These are the core features that users interact with. Newsletter subscriptions directly affect user engagement and growth, while admin authentication protects the system from unauthorized access. Any bugs in these areas would be immediately visible to users and could compromise system security.

**Independent Test**: Can be fully tested by creating unit tests for the Newsletter and Accounts contexts, verifying subscription creation, email verification, magic link generation, and token validation logic. Delivers immediate value by catching regressions in critical user flows.

**Acceptance Scenarios**:

1. **Given** the Newsletter context with subscriber creation logic, **When** tests verify email validation, duplicate prevention, and verification token generation, **Then** all subscription edge cases are covered
2. **Given** the Accounts context with admin authentication, **When** tests verify magic link generation, expiration, and validation, **Then** security vulnerabilities are prevented
3. **Given** existing context functions, **When** developers modify business logic, **Then** tests catch breaking changes immediately

---

### User Story 2 - User-Facing Feature Validation (Priority: P2)

As a developer maintaining the web application, I need integration tests for all user-facing pages and API endpoints so that I can ensure the complete user experience works correctly from request to response.

**Why this priority**: While business logic tests catch internal errors, integration tests validate the entire request-response cycle including routing, controllers, and view rendering. This is essential for maintaining a functional user experience but can build on the foundation of P1 business logic tests.

**Independent Test**: Can be fully tested by creating controller and LiveView tests for each public route (home, blog, newsletter pages) and API endpoint. Delivers value by ensuring users can successfully navigate and interact with all features.

**Acceptance Scenarios**:

1. **Given** all public routes defined in the router, **When** tests simulate HTTP requests to each endpoint, **Then** appropriate content is rendered with correct status codes
2. **Given** the newsletter subscription API endpoint, **When** tests verify subscription requests with valid and invalid data, **Then** proper responses and side effects occur
3. **Given** blog post viewing functionality, **When** tests verify view count incrementation and markdown rendering, **Then** content displays correctly and analytics work

---

### User Story 3 - Admin Portal Protection (Priority: P3)

As a developer maintaining the admin portal, I need tests for admin authentication flows and protected routes so that I can ensure only authorized users can access sensitive functionality.

**Why this priority**: Admin portal security is critical but builds on authentication logic tested in P1. These tests focus on the integration between authentication and route protection rather than core auth logic.

**Independent Test**: Can be fully tested by creating LiveView tests for the admin login flow and verifying the RequireAdmin plug behavior. Delivers value by ensuring the admin portal remains secure during future changes.

**Acceptance Scenarios**:

1. **Given** the admin login LiveView, **When** tests verify email submission, magic link flow, and session creation, **Then** authentication flow works end-to-end
2. **Given** the RequireAdmin plug, **When** tests verify requests to protected routes with and without admin sessions, **Then** unauthorized access is prevented
3. **Given** the admin dashboard, **When** tests verify authenticated admin access, **Then** dashboard functionality is accessible only to admins

---

### User Story 4 - TDD Workflow Enablement (Priority: P4)

As a developer adding new features, I need a test-first workflow with helper utilities and patterns so that I can write tests before implementation and maintain high code quality.

**Why this priority**: This improves the development process for future work but isn't critical for validating existing functionality. It builds on the patterns established in P1-P3.

**Independent Test**: Can be fully tested by creating test helpers for common operations (creating test users, subscribers, blog posts) and documenting TDD patterns. Delivers value by accelerating future test writing.

**Acceptance Scenarios**:

1. **Given** test helper modules with factory functions, **When** developers write new tests, **Then** setup code is reduced and tests are more readable
2. **Given** documented TDD patterns and examples, **When** developers add new features, **Then** they follow test-first practices consistently
3. **Given** the mix test task, **When** developers run tests during development, **Then** fast feedback identifies issues early

---

### Edge Cases

- What happens when tests are run in parallel and database state conflicts occur?
- How does the test suite handle external dependencies like email sending (Swoosh)?
- What happens when testing time-sensitive features like token expiration?
- How are tests isolated from production data and configuration?
- What happens when testing features that depend on session state or authentication?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Test suite MUST cover all Newsletter context functions including subscriber creation, email validation, duplicate prevention, and verification token flows
- **FR-002**: Test suite MUST cover all Accounts context functions including user retrieval, admin verification, and magic link authentication flows
- **FR-003**: Test suite MUST cover all Blog context functions including post listing, retrieval, creation, updating, deletion, and view count incrementation
- **FR-004**: Test suite MUST include controller tests for all public routes including home, about, blog, and contact pages
- **FR-005**: Test suite MUST include API endpoint tests for newsletter subscription with valid and invalid input scenarios
- **FR-006**: Test suite MUST include LiveView tests for admin login flow including email submission and magic link verification
- **FR-007**: Test suite MUST verify admin route protection using the RequireAdmin plug with authenticated and unauthenticated scenarios
- **FR-008**: Test suite MUST verify blog post rendering including markdown conversion and metadata display
- **FR-009**: Test suite MUST use database transactions or sandboxing to ensure test isolation
- **FR-010**: Test suite MUST use test doubles or mocks for email sending to avoid external dependencies during testing
- **FR-011**: Test suite MUST include helper functions for creating test data (users, subscribers, blog posts) to reduce test boilerplate
- **FR-012**: Test suite MUST verify error handling for edge cases including expired tokens, duplicate emails, and invalid input
- **FR-013**: Test suite MUST verify newsletter welcome page displays correctly after successful verification
- **FR-014**: Test suite MUST verify blog post sending to subscribers including recipient counting and status tracking
- **FR-015**: Documentation MUST include examples of TDD workflow for adding new features using test-first approach

### Key Entities *(include if feature involves data)*

- **Test Coverage Metrics**: Represents which code paths are exercised by tests, including line coverage, branch coverage, and function coverage percentages
- **Test Fixtures**: Represents reusable test data including sample users (admin and regular), subscribers (verified and unverified), and blog posts (published and draft)
- **Test Helpers**: Represents utility functions for common test operations including authentication setup, database seeding, and assertion helpers
- **Test Isolation Boundaries**: Represents how tests are separated from each other, including database transaction scoping, session cleanup, and mock configuration

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All context modules (Newsletter, Accounts, Blog) have test coverage above 90% for their public functions
- **SC-002**: All user-facing routes return expected content and status codes when tested
- **SC-003**: All API endpoints handle both success and error scenarios with appropriate responses
- **SC-004**: Test suite runs in under 10 seconds for rapid feedback during development
- **SC-005**: Developers can add new features by writing tests first, with clear examples and patterns documented
- **SC-006**: Zero authentication bypass scenarios - all admin routes require valid admin sessions
- **SC-007**: Test failures clearly indicate which functionality is broken and where to fix it
- **SC-008**: All time-sensitive features (token expiration) can be tested reliably without waiting for real time to pass

## Assumptions

- Tests will use the existing ExUnit framework included with Elixir
- Database tests will use the Ecto SQL Sandbox already configured in Phoenix applications
- Email tests will use Swoosh.TestAssertions for verifying email delivery without sending real emails
- LiveView tests will use Phoenix.LiveViewTest module for simulating user interactions
- Test data will be created in each test rather than using shared fixtures to ensure isolation
- Mock time functions will be used for testing token expiration (via library like Hammox or manual stubbing)
- The test environment database is separate from development and production
- CI/CD integration is not in scope but tests should be runnable in any environment
- Performance benchmarking is not in scope - only functional correctness
- Visual regression testing is not in scope - focus on functionality and data correctness
