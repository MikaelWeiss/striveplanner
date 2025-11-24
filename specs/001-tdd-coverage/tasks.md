# Tasks: Test-Driven Development Implementation

**Input**: Design documents from `/specs/001-tdd-coverage/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/test-contracts.md

**Tests**: This feature IS about implementing tests, so all tasks involve test creation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Context Tests**: `test/strive_planner/` (business logic tests)
- **Web Tests**: `test/strive_planner_web/[controllers|live]/` (controller, LiveView tests)
- **Test Support**: `test/support/fixtures/` (fixtures, helpers)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Configure test environment and create reusable test helpers

- [X] T001 Verify test database is configured in `config/test.exs` with SQL Sandbox mode
- [X] T002 [P] Verify Swoosh test adapter configured in `config/test.exs`
- [X] T003 [P] Verify test support files exist: `test/support/conn_case.ex` and `test/support/data_case.ex`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create test fixtures that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Create Newsletter fixtures module in `test/support/fixtures/newsletter_fixtures.ex` with subscriber_fixture/1, verified_subscriber_fixture/1, subscriber_with_token_fixture/1
- [X] T005 [P] Create Accounts fixtures module in `test/support/fixtures/accounts_fixtures.ex` with user_fixture/1, admin_fixture/1, admin_with_magic_link_fixture/1
- [X] T006 [P] Create Blog fixtures module in `test/support/fixtures/blog_fixtures.ex` with blog_post_fixture/1, published_post_fixture/1, post_with_views_fixture/1, comment_fixture/2

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Core Business Logic Validation (Priority: P1) 🎯 MVP

**Goal**: Implement comprehensive tests for critical business logic (Newsletter and Accounts contexts) to prevent bugs in subscription flows and admin authentication.

**Independent Test**: Run `mix test test/strive_planner/newsletter_test.exs test/strive_planner/accounts_test.exs` to verify all business logic tests pass independently.

### Newsletter Context Tests (US1)

- [X] T007 [P] [US1] Create test file `test/strive_planner/newsletter_test.exs` with describe blocks for create_subscriber/1, get_subscriber_by_email/1, email_subscribed?/1, generate_verification_token/1, verify_subscriber/1
- [X] T008 [US1] Implement create_subscriber/1 tests in `test/strive_planner/newsletter_test.exs`: valid email creation, invalid email error, duplicate email error, unique email generation
- [X] T009 [US1] Implement get_subscriber_by_email/1 tests in `test/strive_planner/newsletter_test.exs`: returns subscriber when exists, returns nil when not exists, case-insensitive matching
- [X] T010 [US1] Implement email_subscribed?/1 tests in `test/strive_planner/newsletter_test.exs`: returns true when subscribed, returns false when not subscribed
- [X] T011 [US1] Implement generate_verification_token/1 tests in `test/strive_planner/newsletter_test.exs`: generates unique token, sets 24-hour expiration, returns error for invalid subscriber
- [X] T012 [US1] Implement verify_subscriber/1 tests in `test/strive_planner/newsletter_test.exs`: verifies with valid token, rejects expired token, rejects invalid token, rejects already verified, marks as verified

### Accounts Context Tests (US1)

- [X] T013 [P] [US1] Create test file `test/strive_planner/accounts_test.exs` with describe blocks for get_user_by_email/1, get_user/1, create_user/1, admin?/1, generate_admin_magic_link/1, verify_admin_magic_link/1
- [X] T014 [US1] Implement get_user_by_email/1 tests in `test/strive_planner/accounts_test.exs`: returns user when exists, returns nil when not exists
- [X] T015 [US1] Implement get_user/1 tests in `test/strive_planner/accounts_test.exs`: returns user when ID exists, returns nil when ID does not exist
- [X] T016 [US1] Implement create_user/1 tests in `test/strive_planner/accounts_test.exs`: creates with valid attributes, error with invalid email, error with duplicate email, defaults role to user
- [X] T017 [US1] Implement admin?/1 tests in `test/strive_planner/accounts_test.exs`: returns true for admin, returns false for regular user
- [X] T018 [US1] Implement generate_admin_magic_link/1 tests in `test/strive_planner/accounts_test.exs`: generates token for admin, error for non-existent user, error for non-admin, sets 15-minute expiration, generates unique token
- [X] T019 [US1] Implement verify_admin_magic_link/1 tests in `test/strive_planner/accounts_test.exs`: verifies with valid token, error with expired token, error with invalid token, clears token after success, error for non-admin

**Checkpoint**: At this point, User Story 1 should be fully functional - all Newsletter and Accounts context tests pass

---

## Phase 4: User Story 2 - User-Facing Feature Validation (Priority: P2)

**Goal**: Implement integration tests for all user-facing pages and API endpoints to ensure complete request-response cycles work correctly.

**Independent Test**: Run `mix test test/strive_planner_web/controllers/` to verify all controller and API endpoint tests pass independently.

### Page Controller Tests (US2)

- [X] T020 [P] [US2] Expand test file `test/strive_planner_web/controllers/page_controller_test.exs` with describe blocks for GET /, GET /about, GET /blog, GET /blog/:slug, GET /newsletter/verify/:token, GET /newsletter/welcome
- [X] T021 [US2] Implement home page tests in `test/strive_planner_web/controllers/page_controller_test.exs`: renders home page, returns 200 status
- [X] T022 [US2] Implement about page tests in `test/strive_planner_web/controllers/page_controller_test.exs`: renders about page, returns 200 status
- [X] T023 [US2] Implement blog index tests in `test/strive_planner_web/controllers/page_controller_test.exs`: lists published posts, does not show drafts
- [X] T024 [US2] Implement blog post show tests in `test/strive_planner_web/controllers/page_controller_test.exs`: shows published post, increments view count, renders markdown, returns 404 for draft, returns 404 for non-existent
- [X] T025 [US2] Implement newsletter verification tests in `test/strive_planner_web/controllers/page_controller_test.exs`: verifies with valid token, redirects to welcome, error for invalid token, error for expired token
- [X] T026 [US2] Implement newsletter welcome page test in `test/strive_planner_web/controllers/page_controller_test.exs`: renders welcome page

### Newsletter API Controller Tests (US2)

- [X] T027 [P] [US2] Create test file `test/strive_planner_web/controllers/api/newsletter_controller_test.exs` with describe block for POST /api/newsletter/subscribe
- [X] T028 [US2] Implement newsletter subscription API tests in `test/strive_planner_web/controllers/api/newsletter_controller_test.exs`: creates subscriber and sends email, returns success JSON, error for invalid email, error for duplicate, sends verification email with token

### Blog Context Tests (US2)

- [X] T029 [P] [US2] Create test file `test/strive_planner/blog_test.exs` with describe blocks for list_posts/0, list_all_posts/0, get_post/1, get_post!/1, create_post/1, update_post/2, delete_post/1, increment_view_count/1, render_markdown/1, send_to_subscribers/1
- [X] T030 [US2] Implement list_posts/0 tests in `test/strive_planner/blog_test.exs`: returns published posts, excludes drafts, orders by published_at desc, returns empty when none
- [X] T031 [US2] Implement list_all_posts/0 tests in `test/strive_planner/blog_test.exs`: returns all including drafts, orders by updated_at desc
- [X] T032 [US2] Implement get_post/1 tests in `test/strive_planner/blog_test.exs`: returns published by slug, error for draft, error for non-existent
- [X] T033 [US2] Implement get_post!/1 tests in `test/strive_planner/blog_test.exs`: returns post by ID, raises for non-existent
- [X] T034 [US2] Implement create_post/1 tests in `test/strive_planner/blog_test.exs`: creates with valid attributes, error with invalid, generates unique slug
- [X] T035 [US2] Implement update_post/2 tests in `test/strive_planner/blog_test.exs`: updates with valid attributes, error with invalid
- [X] T036 [US2] Implement delete_post/1 tests in `test/strive_planner/blog_test.exs`: deletes post, error for non-existent
- [X] T037 [US2] Implement increment_view_count/1 tests in `test/strive_planner/blog_test.exs`: increments by 1, handles multiple increments
- [X] T038 [US2] Implement render_markdown/1 tests in `test/strive_planner/blog_test.exs`: converts markdown to HTML, returns empty for nil, returns original on parse error
- [X] T039 [US2] Implement send_to_subscribers/1 tests in `test/strive_planner/blog_test.exs`: sends to verified subscribers, returns count, updates post metadata, error when no subscribers

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - all context, controller, and API tests pass

---

## Phase 5: User Story 3 - Admin Portal Protection (Priority: P3)

**Goal**: Implement tests for admin authentication flows and protected routes to ensure only authorized users can access sensitive functionality.

**Independent Test**: Run `mix test test/strive_planner_web/live/admin/` to verify all admin LiveView tests pass independently.

### Admin Login LiveView Tests (US3)

- [ ] T040 [P] [US3] Create test file `test/strive_planner_web/live/admin/login_live_test.exs` with describe blocks for mount and handle_event submit
- [ ] T041 [US3] Implement mount tests in `test/strive_planner_web/live/admin/login_live_test.exs`: renders login form, shows email input
- [ ] T042 [US3] Implement handle_event submit tests in `test/strive_planner_web/live/admin/login_live_test.exs`: sends magic link to admin, shows success message, error for non-existent user, error for non-admin, sends email with magic link

### Admin Dashboard LiveView Tests (US3)

- [ ] T043 [P] [US3] Create test file `test/strive_planner_web/live/admin/dashboard_live_test.exs` with describe blocks for mount with authentication and mount without authentication
- [ ] T044 [US3] Implement authenticated mount tests in `test/strive_planner_web/live/admin/dashboard_live_test.exs`: renders dashboard, shows admin content
- [ ] T045 [US3] Implement unauthenticated mount tests in `test/strive_planner_web/live/admin/dashboard_live_test.exs`: redirects to login

**Checkpoint**: All user stories should now be independently functional - complete test coverage for Newsletter, Accounts, Blog contexts and all web layers

---

## Phase 6: User Story 4 - TDD Workflow Enablement (Priority: P4)

**Goal**: Document TDD patterns and best practices to enable test-first development for future features.

**Independent Test**: Verify documentation exists and provides clear examples by reading the files.

### Documentation Tasks (US4)

- [X] T046 [P] [US4] Update project README.md with TDD workflow section referencing `specs/001-tdd-coverage/quickstart.md`
- [X] T047 [P] [US4] Add code comments in fixture files explaining the fixture pattern in `test/support/fixtures/newsletter_fixtures.ex`, `test/support/fixtures/accounts_fixtures.ex`, `test/support/fixtures/blog_fixtures.ex`
- [X] T048 [US4] Document common test patterns as @moduledoc in `test/strive_planner/newsletter_test.exs` demonstrating arrange-act-assert structure

**Checkpoint**: Documentation complete - future developers can follow TDD patterns consistently

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T049 [P] Run full test suite with coverage: `mix test --cover` and verify 90%+ coverage for all context modules
- [X] T050 [P] Run precommit checks: `mix precommit` to ensure code quality
- [X] T051 [P] Verify test suite completes in under 10 seconds: `mix test --slowest`
- [X] T052 Add project-wide test documentation in `test/README.md` explaining test structure and conventions
- [X] T053 Review and optimize slow tests identified by `mix test --slowest`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3 → P4)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Independently testable (does not require US1)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Builds on Accounts context from US1 but independently testable
- **User Story 4 (P4)**: Can start after Foundational (Phase 2) - Documentation only, no code dependencies

### Within Each User Story

- Tests are grouped by context/controller/LiveView module
- All tests for a given module can be written in sequence within that test file
- Tests within same describe block should test same function with different scenarios
- Follow arrange-act-assert pattern consistently

### Parallel Opportunities

- All Setup tasks (T001-T003) can run in parallel
- All Foundational fixture tasks (T004-T006) can run in parallel
- Once Foundational phase completes, all user stories can start in parallel:
  - US1: Newsletter + Accounts context tests (T007-T019)
  - US2: Controllers + Blog context tests (T020-T039)
  - US3: Admin LiveView tests (T040-T045)
  - US4: Documentation (T046-T048)
- Within US1: Newsletter tests (T007-T012) and Accounts tests (T013-T019) can run in parallel
- Within US2: Page controller (T020-T026), API controller (T027-T028), and Blog context (T029-T039) can run in parallel
- Within US3: Admin login tests (T040-T042) and dashboard tests (T043-T045) can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch Newsletter and Accounts context tests in parallel:
# Terminal 1: Newsletter context tests
mix test test/strive_planner/newsletter_test.exs

# Terminal 2: Accounts context tests
mix test test/strive_planner/accounts_test.exs

# Both test files are independent and can be worked on simultaneously
```

---

## Parallel Example: User Story 2

```bash
# Launch all US2 test files in parallel:
# Terminal 1: Page controller tests
mix test test/strive_planner_web/controllers/page_controller_test.exs

# Terminal 2: Newsletter API tests
mix test test/strive_planner_web/controllers/api/newsletter_controller_test.exs

# Terminal 3: Blog context tests
mix test test/strive_planner/blog_test.exs

# All three are independent and test different modules
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T006) - CRITICAL, blocks all stories
3. Complete Phase 3: User Story 1 (T007-T019)
4. **STOP and VALIDATE**: Run `mix test test/strive_planner/newsletter_test.exs test/strive_planner/accounts_test.exs --cover`
5. Verify 90%+ coverage for Newsletter and Accounts contexts
6. **MVP COMPLETE**: Core business logic is now fully tested and protected from regressions

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 (T007-T019) → Test independently → **Deploy/Demo (MVP!)**
3. Add User Story 2 (T020-T039) → Test independently → Deploy/Demo
4. Add User Story 3 (T040-T045) → Test independently → Deploy/Demo
5. Add User Story 4 (T046-T048) → Validate documentation → Deploy/Demo
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T006)
2. Once Foundational is done:
   - **Developer A**: User Story 1 - Newsletter + Accounts context tests (T007-T019)
   - **Developer B**: User Story 2 - Controllers + Blog context tests (T020-T039)
   - **Developer C**: User Story 3 - Admin LiveView tests (T040-T045)
   - **Developer D**: User Story 4 - Documentation (T046-T048)
3. Stories complete and integrate independently
4. Run full test suite: `mix test --cover` to verify everything works together

---

## Notes

- [P] tasks = different files, no dependencies - can run truly in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Use `async: true` in test modules where possible for faster execution
- Follow Phoenix test conventions: context tests in `test/strive_planner/`, web tests in `test/strive_planner_web/`
- Import fixtures at top of test files: `import StrivePlanner.NewsletterFixtures`
- Use Swoosh.TestAssertions for email testing: `import Swoosh.TestAssertions`
- Commit after each completed test file or logical group of tests
- Stop at any checkpoint to validate story independently before proceeding

---

## Summary Statistics

- **Total Tasks**: 53
- **User Story 1 Tasks**: 13 (T007-T019) - Newsletter + Accounts context tests
- **User Story 2 Tasks**: 20 (T020-T039) - Controllers + Blog context tests
- **User Story 3 Tasks**: 6 (T040-T045) - Admin LiveView tests
- **User Story 4 Tasks**: 3 (T046-T048) - Documentation
- **Parallel Opportunities**: 30+ tasks can run in parallel within their phases
- **Suggested MVP Scope**: Phase 1 + Phase 2 + Phase 3 (US1) = 19 tasks
- **Independent Test Criteria**:
  - US1: `mix test test/strive_planner/newsletter_test.exs test/strive_planner/accounts_test.exs`
  - US2: `mix test test/strive_planner_web/controllers/ test/strive_planner/blog_test.exs`
  - US3: `mix test test/strive_planner_web/live/admin/`
  - US4: Verify documentation files exist and are complete
