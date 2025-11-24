# Tasks: Blog Post Management and Mailing List

**Input**: Design documents from `/specs/001-blog-mailing/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: TDD is mandatory per constitution - tests are included for all functionality

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Phoenix Business Logic**: `lib/strive_planner/[context]/` (e.g., `lib/strive_planner/blog/`)
- **Phoenix Web Layer**: `lib/strive_planner_web/[live|controllers|components]/[context]/`
- **Context Tests**: `test/strive_planner/[context]/` (business logic tests)
- **Web Tests**: `test/strive_planner_web/[live|controllers]/[context]/` (LiveView, controller tests)
- **Test Support**: `test/support/` (fixtures, helpers)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependencies

- [X] T001 Add Oban dependency to mix.exs (version ~> 2.18)
- [X] T002 Run `mix deps.get` to install Oban
- [X] T003 Configure Oban in config/config.exs (emails queue, pruner, cron for EmailScheduler)
- [X] T004 Add Oban supervisor to lib/strive_planner/application.ex

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Create migration to add subscription_status to subscribers table in priv/repo/migrations/YYYYMMDDHHMMSS_add_subscription_status_to_subscribers.exs
- [X] T006 Create migration to add index on blog_posts scheduled_email_for in priv/repo/migrations/YYYYMMDDHHMMSS_add_scheduled_email_index_to_blog_posts.exs
- [X] T007 Run `mix ecto.migrate` to apply database migrations
- [X] T008 [P] Update Subscriber schema to add subscription_status field in lib/strive_planner/newsletter/subscriber.ex
- [X] T009 [P] Create Oban EmailScheduler worker in lib/strive_planner/workers/email_scheduler.ex
- [X] T010 [P] Extend test fixtures for subscribers in test/support/fixtures/newsletter_fixtures.ex (add subscription_status)
- [X] T011 [P] Extend test fixtures for blog posts in test/support/fixtures/blog_fixtures.ex (add scheduled_email_for)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Blog Post Lifecycle Management (Priority: P1) 🎯 MVP

**Goal**: Enable admins to create, publish, and unpublish blog posts with full control over lifecycle states (draft/published)

**Independent Test**: Create a blog post as draft, publish it, verify it's visible on website, unpublish it, verify it's removed from website but still exists in admin

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T012 [P] [US1] Write context test for Blog.publish_post/1 in test/strive_planner/blog/blog_test.exs (test publishes draft and sets published_at)
- [X] T013 [P] [US1] Write context test for Blog.unpublish_post/1 in test/strive_planner/blog/blog_test.exs (test unpublishes and cancels scheduled email)
- [X] T014 [P] [US1] Write LiveView test for publishing blog post in test/strive_planner_web/live/admin/blog_post_live_test.exs (test publish event)
- [X] T015 [P] [US1] Write LiveView test for unpublishing blog post in test/strive_planner_web/live/admin/blog_post_live_test.exs (test unpublish event)

### Implementation for User Story 1

- [X] T016 [US1] Implement Blog.publish_post/1 function in lib/strive_planner/blog.ex (sets status=published, sets published_at)
- [X] T017 [US1] Implement Blog.unpublish_post/1 function in lib/strive_planner/blog.ex (sets status=draft, cancels scheduled email, clears scheduled_email_for)
- [X] T018 [US1] Add publish event handler to BlogPostLive.Index in lib/strive_planner_web/live/admin/blog_post_live/index.ex
- [X] T019 [US1] Add unpublish event handler to BlogPostLive.Index in lib/strive_planner_web/live/admin/blog_post_live/index.ex
- [X] T020 [US1] Verify all tests pass for User Story 1 (`mix test test/strive_planner/blog/blog_test.exs test/strive_planner_web/live/admin/blog_post_live_test.exs`)

**Checkpoint**: At this point, User Story 1 should be fully functional - admins can publish and unpublish posts

---

## Phase 4: User Story 2 - Email Delivery Scheduling (Priority: P2)

**Goal**: Enable admins to schedule blog post emails independently from publication date

**Independent Test**: Create a published blog post, set scheduled email date, verify "scheduled" status shows in admin, later verify email sends at scheduled time

**Dependencies**: Depends on US1 (need published posts to schedule emails for)

### Tests for User Story 2

- [X] T021 [P] [US2] Write context test for Blog.schedule_email/2 in test/strive_planner/blog/blog_test.exs (test sets scheduled_email_for and enqueues Oban job)
- [X] T022 [P] [US2] Write context test for Blog.cancel_scheduled_email/1 in test/strive_planner/blog/blog_test.exs (test clears scheduled_email_for and cancels job)
- [X] T023 [P] [US2] Write context test for Blog.process_scheduled_emails/0 in test/strive_planner/blog/blog_test.exs (test sends emails for due posts)
- [X] T024 [P] [US2] Write worker test for EmailScheduler in test/strive_planner/workers/email_scheduler_test.exs (test performs job and calls process_scheduled_emails)
- [X] T025 [P] [US2] Write LiveView test for scheduling email via form in test/strive_planner_web/live/admin/blog_post_live_test.exs (test form submission with scheduled_email_for)

### Implementation for User Story 2

- [X] T026 [US2] Implement Blog.schedule_email/2 function in lib/strive_planner/blog.ex (sets scheduled_email_for, enqueues Oban job)
- [X] T027 [US2] Implement Blog.cancel_scheduled_email/1 function in lib/strive_planner/blog.ex (clears scheduled_email_for, cancels Oban job)
- [X] T028 [US2] Implement Blog.process_scheduled_emails/0 function in lib/strive_planner/blog.ex (queries due posts, sends emails)
- [X] T029 [US2] Implement private Blog.enqueue_email_job/1 helper in lib/strive_planner/blog.ex (creates Oban job)
- [X] T030 [US2] Implement private Blog.cancel_email_job/1 helper in lib/strive_planner/blog.ex (deletes Oban job)
- [X] T031 [US2] Implement EmailScheduler.perform/1 worker in lib/strive_planner/workers/email_scheduler.ex (calls Blog.process_scheduled_emails/0)
- [X] T032 [US2] Extend BlogPostLive.FormComponent to add scheduled_email_for datetime field in lib/strive_planner_web/live/admin/blog_post_live/form_component.ex
- [X] T033 [US2] Update BlogPost.changeset to validate scheduled_email_for (must be future) in lib/strive_planner/blog/blog_post.ex
- [X] T034 [US2] Verify all tests pass for User Story 2 (`mix test test/strive_planner/blog/blog_test.exs test/strive_planner/workers/email_scheduler_test.exs`)

**Checkpoint**: At this point, admins can schedule emails for blog posts, and emails send automatically

---

## Phase 5: User Story 3 - Mailing List Management (Priority: P2)

**Goal**: Enable admins to view and manage all newsletter subscribers (CRUD operations)

**Independent Test**: Navigate to subscriber management page, add new subscriber, edit email, delete subscriber, verify all CRUD operations work

**Dependencies**: None - can be implemented in parallel with US2

### Tests for User Story 3

- [X] T035 [P] [US3] Write context test for Newsletter.list_subscribers/0 in test/strive_planner/newsletter/newsletter_test.exs (test returns all subscribers)
- [X] T036 [P] [US3] Write context test for Newsletter.create_subscriber/1 in test/strive_planner/newsletter/newsletter_test.exs (test creates subscriber with defaults)
- [X] T037 [P] [US3] Write context test for Newsletter.update_subscriber/2 in test/strive_planner/newsletter/newsletter_test.exs (test updates email)
- [X] T038 [P] [US3] Write context test for Newsletter.delete_subscriber/1 in test/strive_planner/newsletter/newsletter_test.exs (test deletes subscriber)
- [X] T039 [P] [US3] Write context test for Newsletter.list_verified_subscribed_subscribers/0 in test/strive_planner/newsletter/newsletter_test.exs (test filters by verified and subscribed)
- [X] T040 [P] [US3] Write LiveView test for subscriber index in test/strive_planner_web/live/admin/subscriber_live_test.exs (test lists subscribers)
- [X] T041 [P] [US3] Write LiveView test for create subscriber in test/strive_planner_web/live/admin/subscriber_live_test.exs (test form submission)
- [X] T042 [P] [US3] Write LiveView test for update subscriber in test/strive_planner_web/live/admin/subscriber_live_test.exs (test edit form)
- [X] T043 [P] [US3] Write LiveView test for delete subscriber in test/strive_planner_web/live/admin/subscriber_live_test.exs (test delete event)

### Implementation for User Story 3

- [X] T044 [P] [US3] Implement Newsletter.list_subscribers/0 in lib/strive_planner/newsletter.ex
- [X] T045 [P] [US3] Implement Newsletter.list_verified_subscribed_subscribers/0 in lib/strive_planner/newsletter.ex
- [X] T046 [P] [US3] Implement Newsletter.get_subscriber!/1 in lib/strive_planner/newsletter.ex
- [X] T047 [P] [US3] Implement Newsletter.create_subscriber/1 in lib/strive_planner/newsletter.ex
- [X] T048 [P] [US3] Implement Newsletter.update_subscriber/2 in lib/strive_planner/newsletter.ex
- [X] T049 [P] [US3] Implement Newsletter.delete_subscriber/1 in lib/strive_planner/newsletter.ex
- [X] T050 [P] [US3] Implement Newsletter.change_subscriber/2 in lib/strive_planner/newsletter.ex
- [X] T051 [US3] Create SubscriberLive.Index module in lib/strive_planner_web/live/admin/subscriber_live/index.ex
- [X] T052 [US3] Create SubscriberLive.Show module in lib/strive_planner_web/live/admin/subscriber_live/show.ex
- [X] T053 [US3] Create SubscriberLive.FormComponent module in lib/strive_planner_web/live/admin/subscriber_live/form_component.ex
- [X] T054 [US3] Add subscriber management routes to router in lib/strive_planner_web/router.ex (admin scope)
- [X] T055 [US3] Verify all tests pass for User Story 3 (`mix test test/strive_planner/newsletter/ test/strive_planner_web/live/admin/subscriber_live_test.exs`)

**Checkpoint**: At this point, admins can fully manage subscriber list via admin UI

---

## Phase 6: User Story 5 - Email Notification with Unsubscribe (Priority: P2)

**Goal**: Send blog post emails to verified subscribers with compliant unsubscribe functionality

**Independent Test**: Trigger scheduled email send, receive email as test subscriber, click unsubscribe link, verify confirmation page and subscription_status changes to "unsubscribed"

**Dependencies**: Depends on US2 (email scheduling) and US3 (subscriber management)

### Tests for User Story 5

- [X] T056 [P] [US5] Write context test for Newsletter.unsubscribe/1 in test/strive_planner/newsletter/newsletter_test.exs (test sets subscription_status to unsubscribed)
- [X] T057 [P] [US5] Write context test for Newsletter.get_subscriber_by_email/1 in test/strive_planner/newsletter/newsletter_test.exs (test finds subscriber by email)
- [X] T058 [P] [US5] Write controller test for unsubscribe with valid token in test/strive_planner_web/controllers/newsletter/unsubscribe_controller_test.exs
- [X] T059 [P] [US5] Write controller test for unsubscribe with invalid token in test/strive_planner_web/controllers/newsletter/unsubscribe_controller_test.exs
- [X] T060 [P] [US5] Write context test for Blog.send_to_subscribers/1 filtering in test/strive_planner/blog/blog_test.exs (test only sends to verified+subscribed)

### Implementation for User Story 5

- [X] T061 [P] [US5] Implement Newsletter.unsubscribe/1 in lib/strive_planner/newsletter.ex
- [X] T062 [P] [US5] Implement Newsletter.get_subscriber_by_email/1 in lib/strive_planner/newsletter.ex
- [X] T063 [US5] Update Blog.send_to_subscribers/1 to filter by subscription_status in lib/strive_planner/blog.ex
- [X] T064 [US5] Create UnsubscribeController module in lib/strive_planner_web/controllers/newsletter/unsubscribe_controller.ex
- [X] T065 [US5] Create UnsubscribeHTML module in lib/strive_planner_web/controllers/newsletter/unsubscribe_html.ex
- [X] T066 [US5] Create unsubscribe.html.heex template in lib/strive_planner_web/controllers/newsletter/unsubscribe_html/unsubscribe.html.heex
- [X] T067 [US5] Extend Email module to generate unsubscribe tokens in lib/strive_planner/email.ex (use Phoenix.Token.sign)
- [X] T068 [US5] Extend Email module blog post template to include unsubscribe link in lib/strive_planner/email.ex
- [X] T069 [US5] Add public unsubscribe route to router in lib/strive_planner_web/router.ex (GET /unsubscribe)
- [X] T070 [US5] Verify all tests pass for User Story 5 (`mix test test/strive_planner/newsletter/ test/strive_planner_web/controllers/newsletter/`)

**Checkpoint**: At this point, email sending respects subscription status and unsubscribe works

---

## Phase 7: User Story 4 - Admin Sidebar Status Display (Priority: P3)

**Goal**: Display email status (scheduled/sent) in admin sidebar for quick visibility

**Independent Test**: View admin sidebar with posts in different states (scheduled, sent, no schedule) and verify correct badges display

**Dependencies**: Depends on US2 (email scheduling) to have status to display

### Tests for User Story 4

- [X] T071 [P] [US4] Write LiveView test for sidebar scheduled status in test/strive_planner_web/live/admin/blog_post_live_test.exs (test scheduled badge renders)
- [X] T072 [P] [US4] Write LiveView test for sidebar sent status in test/strive_planner_web/live/admin/blog_post_live_test.exs (test sent badge renders)
- [X] T073 [P] [US4] Write LiveView test for sidebar no status in test/strive_planner_web/live/admin/blog_post_live_test.exs (test no badge when no schedule)

### Implementation for User Story 4

- [X] T074 [P] [US4] Create email_status_badge component in lib/strive_planner_web/components/admin_components.ex (renders badge based on post state)
- [X] T075 [US4] Extend BlogPostLive.Index mount to query posts with email status in lib/strive_planner_web/live/admin/blog_post_live/index.ex
- [X] T076 [US4] Add email status badge to sidebar in BlogPostLive.Index template in lib/strive_planner_web/live/admin/blog_post_live/index.html.heex
- [X] T077 [US4] Verify all tests pass for User Story 4 (`mix test test/strive_planner_web/live/admin/blog_post_live_test.exs`)

**Checkpoint**: At this point, all user stories are complete and independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements affecting multiple user stories

- [X] T078 [P] Add @moduledoc and @doc to all new context functions in lib/strive_planner/blog.ex and lib/strive_planner/newsletter.ex
- [X] T079 [P] Run `mix format` to format all code
- [X] T080 [P] Run `mix credo` and fix any issues
- [X] T081 [P] Optimize Ecto queries for N+1 issues (use preload where needed)
- [X] T082 [P] Add database indexes if missing (check query plans)
- [X] T083 Verify all acceptance scenarios from spec.md work end-to-end
- [X] T084 Run full test suite (`mix test`) and verify 100% pass rate
- [X] T085 Run `mix precommit` alias (compile, format, test)
- [ ] T086 Manual testing: Create draft, publish, schedule email, unpublish, verify cancellation
- [ ] T087 Manual testing: Add subscriber, trigger email send, click unsubscribe, verify status change
- [ ] T088 Review quickstart.md and verify all examples work

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 (P1): Can start after Foundational - No dependencies on other stories
  - US2 (P2): Can start after Foundational - Integrates with US1 but independently testable
  - US3 (P2): Can start after Foundational - No dependencies on other stories (PARALLEL with US2)
  - US5 (P2): Depends on US2 + US3 completion (needs scheduling + subscriber management)
  - US4 (P3): Depends on US2 completion (needs email status to display)
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

```
Foundational (Phase 2)
    ├── US1 (P1) - Blog Post Lifecycle ✓ Can start immediately after foundational
    ├── US2 (P2) - Email Scheduling ✓ Can start immediately after foundational
    │       └── US4 (P3) - Sidebar Status (needs US2 for status to display)
    ├── US3 (P2) - Subscriber Management ✓ Can start immediately after foundational
    └── US2 + US3 → US5 (P2) - Unsubscribe (needs both email scheduling and subscribers)
```

### Within Each User Story

- Tests MUST be written and FAIL before implementation (Red-Green-Refactor)
- Context functions before LiveViews/Controllers
- Core functionality before UI
- Story complete before moving to next priority

### Parallel Opportunities

**Setup Phase (can run all in parallel)**:
- T001, T002, T003, T004

**Foundational Phase (can run marked [P] in parallel)**:
- T008, T009, T010, T011 (after migrations T005-T007 complete)

**User Story Tests (within each story, marked [P] can run together)**:
- US1: T012, T013, T014, T015
- US2: T021, T022, T023, T024, T025
- US3: T035-T043 (all test tasks)
- US5: T056-T060 (all test tasks)
- US4: T071, T072, T073

**User Story Implementation (some tasks marked [P])**:
- US3 context functions: T044-T050 (all parallel - different functions)
- US5: T061, T062, T065, T066, T067, T068 (different files)
- US4: T074 (parallel with others)

**After Foundational Phase**:
- US1 (P1), US2 (P2), and US3 (P2) can ALL start in parallel (different team members)
- US5 must wait for US2 + US3 to complete
- US4 must wait for US2 to complete

**Polish Phase (can run most in parallel)**:
- T078, T079, T080, T081, T082 (different files/tasks)

---

## Parallel Example: User Story 2 Tests

```bash
# Launch all tests for User Story 2 together:
Task: "Write context test for Blog.schedule_email/2 in test/strive_planner/blog/blog_test.exs"
Task: "Write context test for Blog.cancel_scheduled_email/1 in test/strive_planner/blog/blog_test.exs"
Task: "Write context test for Blog.process_scheduled_emails/0 in test/strive_planner/blog/blog_test.exs"
Task: "Write worker test for EmailScheduler in test/strive_planner/workers/email_scheduler_test.exs"
Task: "Write LiveView test for scheduling email via form in test/strive_planner_web/live/admin/blog_post_live_test.exs"

# All these tests can be written simultaneously since they test different functions/files
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T011) - CRITICAL
3. Complete Phase 3: User Story 1 (T012-T020)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo - admin can publish/unpublish posts

**MVP Deliverable**: Blog post lifecycle management (draft/published/unpublished)

### Incremental Delivery (Recommended)

1. Setup + Foundational → Foundation ready
2. **Add US1** → Test independently → Deploy/Demo (MVP!)
3. **Add US2** → Test independently → Deploy/Demo (email scheduling)
4. **Add US3** (in parallel with US2 if staffed) → Test independently → Deploy/Demo (subscriber management)
5. **Add US5** (after US2+US3) → Test independently → Deploy/Demo (unsubscribe functionality)
6. **Add US4** (after US2) → Test independently → Deploy/Demo (sidebar polish)
7. Polish phase → Final deployment

Each story adds value without breaking previous stories.

### Parallel Team Strategy

With multiple developers after Foundational phase:

1. **Team completes Setup + Foundational together** (T001-T011)
2. **Once Foundational is done**:
   - Developer A: User Story 1 (T012-T020)
   - Developer B: User Story 2 (T021-T034)
   - Developer C: User Story 3 (T035-T055)
3. **After US2 + US3 complete**:
   - Any developer: User Story 5 (T056-T070)
   - Any developer: User Story 4 (T071-T077)
4. Stories integrate independently

---

## Task Count Summary

- **Setup**: 4 tasks
- **Foundational**: 7 tasks (BLOCKING)
- **User Story 1 (P1)**: 9 tasks (4 tests + 5 implementation)
- **User Story 2 (P2)**: 14 tasks (5 tests + 9 implementation)
- **User Story 3 (P2)**: 21 tasks (9 tests + 12 implementation)
- **User Story 5 (P2)**: 15 tasks (5 tests + 10 implementation)
- **User Story 4 (P3)**: 7 tasks (3 tests + 4 implementation)
- **Polish**: 11 tasks
- **TOTAL**: 88 tasks

**Parallel opportunities**: 40+ tasks marked [P] can run concurrently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- **TDD Required**: Write tests first, ensure they FAIL, then implement (Red-Green-Refactor)
- Verify tests pass after each user story implementation
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Run `mix precommit` before final completion
