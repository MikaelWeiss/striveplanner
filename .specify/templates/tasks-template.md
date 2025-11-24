---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

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
- Paths shown below follow Phoenix conventions - adjust based on specific contexts in plan.md

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create Phoenix context(s) per implementation plan (use `mix phx.gen.context`)
- [ ] T002 Setup database migrations for new schemas
- [ ] T003 [P] Configure Credo and formatter (if not already configured)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Run database migrations to create shared schemas
- [ ] T005 [P] Setup authentication context (if needed, e.g., `StrivePlanner.Accounts`)
- [ ] T006 [P] Configure router scopes and pipelines in `lib/strive_planner_web/router.ex`
- [ ] T007 Create shared Ecto schemas that all stories depend on
- [ ] T008 Configure error handling in `lib/strive_planner_web/` components
- [ ] T009 Setup environment configuration in `config/` if needed

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T010 [P] [US1] Context test for [Context] in test/strive_planner/[context]/[context]_test.exs
- [ ] T011 [P] [US1] LiveView test for [feature] in test/strive_planner_web/live/[context]/[live]_test.exs

### Implementation for User Story 1

- [ ] T012 [P] [US1] Create [Schema1] schema in lib/strive_planner/[context]/[schema1].ex
- [ ] T013 [P] [US1] Create [Schema2] schema in lib/strive_planner/[context]/[schema2].ex
- [ ] T014 [US1] Implement context functions in lib/strive_planner/[context].ex (depends on T012, T013)
- [ ] T015 [US1] Implement LiveView in lib/strive_planner_web/live/[context]/[live].ex
- [ ] T016 [US1] Add changeset validation and error handling in schemas/context
- [ ] T017 [US1] Add logging for user story 1 operations (use Logger)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T018 [P] [US2] Context test for [Context] in test/strive_planner/[context]/[context]_test.exs
- [ ] T019 [P] [US2] LiveView test for [feature] in test/strive_planner_web/live/[context]/[live]_test.exs

### Implementation for User Story 2

- [ ] T020 [P] [US2] Create [Schema] in lib/strive_planner/[context]/[schema].ex
- [ ] T021 [US2] Implement context functions in lib/strive_planner/[context].ex
- [ ] T022 [US2] Implement LiveView in lib/strive_planner_web/live/[context]/[live].ex
- [ ] T023 [US2] Integrate with User Story 1 context functions (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T024 [P] [US3] Context test for [Context] in test/strive_planner/[context]/[context]_test.exs
- [ ] T025 [P] [US3] LiveView test for [feature] in test/strive_planner_web/live/[context]/[live]_test.exs

### Implementation for User Story 3

- [ ] T026 [P] [US3] Create [Schema] in lib/strive_planner/[context]/[schema].ex
- [ ] T027 [US3] Implement context functions in lib/strive_planner/[context].ex
- [ ] T028 [US3] Implement LiveView in lib/strive_planner_web/live/[context]/[live].ex

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/ or inline @doc/@moduledoc
- [ ] TXXX Code cleanup and refactoring (run `mix format`, `mix credo`)
- [ ] TXXX Performance optimization across all stories (Ecto query optimization, etc.)
- [ ] TXXX [P] Additional context/LiveView tests (if requested)
- [ ] TXXX Security hardening (CSRF, XSS, input validation)
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Context test for Blog in test/strive_planner/blog/blog_test.exs"
Task: "LiveView test for post listing in test/strive_planner_web/live/blog/post_live_test.exs"

# Launch all schemas for User Story 1 together:
Task: "Create Post schema in lib/strive_planner/blog/post.ex"
Task: "Create Comment schema in lib/strive_planner/blog/comment.ex"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
