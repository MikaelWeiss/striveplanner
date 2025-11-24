# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The following checks ensure alignment with the StrivePlanner Constitution (v2.1.0):

### Principle I: User Empowerment First
- [ ] Feature reduces friction and eliminates confusion in user flows
- [ ] Language and UI elements are encouraging and motivating
- [ ] Feature helps users define goals and provides actionable paths
- [ ] Content provides tangible value toward goal achievement

### Principle II: Jony Ive Design Philosophy
- [ ] Design feels inevitable and fades into background
- [ ] Whitespace is generous (2-3x standard spacing minimum)
- [ ] Interactive elements use soft rounded corners (12px+ border-radius)
- [ ] Color palette is calming (earth tones, soft blues, warm neutrals)
- [ ] Interactions are intuitive without requiring instructions
- [ ] Visual hierarchy through typography/spacing, not color/decoration
- [ ] Every element justifies its existence

### Principle III: Test-First Development
- [ ] Tests will be written before implementation
- [ ] TDD Red-Green-Refactor cycle planned
- [ ] Test categories identified (context tests, API tests, etc.)
- [ ] Tests focus on functional behavior, NOT UI presentation
- [ ] Tests verify data flow, API contracts, and business logic

### Principle IV: Phoenix Conventions & Contexts
- [ ] Phoenix Contexts define clear domain boundaries
- [ ] Each context exposes well-defined public API
- [ ] Contexts do not call other contexts' private functions
- [ ] Business logic resides in contexts, not controllers/LiveViews
- [ ] Follows `lib/strive_planner/` (business) and `lib/strive_planner_web/` (web) separation
- [ ] Ecto schemas live within their respective contexts
- [ ] Database queries composed in context modules using Ecto.Query
- [ ] Changesets created in schema/context modules, not controllers/LiveViews

### Principle V: Content-Driven Experience
- [ ] Blog posts are concise and focused on one principle (if applicable)
- [ ] Content has clear, achievable promise (if applicable)
- [ ] Tone is encouraging and motivating (if applicable)
- [ ] Community interactions facilitate meaningful support (if applicable)

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
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Expand the structure with real Phoenix contexts and modules.
  The delivered plan must specify actual context names (e.g., Blog, Accounts, Community).
-->

```text
# Phoenix Project Structure (StrivePlanner)
lib/strive_planner/
├── [context_name]/               # e.g., blog/, accounts/, community/
│   ├── [schema].ex              # Ecto schemas
│   └── [nested_context]/        # Sub-contexts if needed
└── application.ex               # Application supervisor

lib/strive_planner_web/
├── controllers/
│   └── [context_name]/          # Controllers grouped by context
├── live/
│   └── [context_name]/          # LiveViews grouped by context
├── components/
│   ├── core_components.ex       # Shared components
│   └── [feature]_components.ex  # Feature-specific components
├── layouts/
│   ├── root.html.heex
│   └── app.html.heex
└── router.ex

test/strive_planner/
└── [context_name]/              # Context tests (business logic)

test/strive_planner_web/
├── controllers/
│   └── [context_name]/          # Controller tests
└── live/
    └── [context_name]/          # LiveView tests

test/support/
├── fixtures/                     # Test data factories
├── conn_case.ex                 # Test helpers for controllers
└── data_case.ex                 # Test helpers for contexts
```

**Structure Decision**: [Document which Phoenix contexts will be created/modified
and how they align with domain boundaries. Reference specific contexts like
`StrivePlanner.Blog`, `StrivePlanner.Accounts`, etc.]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
