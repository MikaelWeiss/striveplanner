<!--
SYNC IMPACT REPORT
==================

Version Change: 2.0.0 → 2.1.0 (MINOR - Testing principle expanded)

Modified Principles:
- Principle III: "Test-First Development" expanded with UI testing exclusion guidance
  - Added: Explicit exclusion of UI presentation tests (element existence, styling validation)
  - Added: Focus on functional behavior testing only
  - Clarification: Tests should verify functionality, not UI implementation details

Added Sections: N/A

Removed Sections: N/A

Templates Requiring Updates:
- ✅ plan-template.md - Updated constitution version to 2.1.0, added functional testing checklist items
- ✅ spec-template.md - No changes needed (user scenarios focus on functionality)
- ✅ tasks-template.md - No changes needed (task structure unaffected)
- ✅ checklist-template.md - No changes needed (adapts automatically)
- ✅ agent-file-template.md - No changes needed (adapts automatically)

Follow-up TODOs: None

Rationale:
UI tests that check for specific elements or styling are brittle and provide low value. They break when design changes even if functionality remains correct. Functional tests that verify behavior (data flow, API responses, business logic) are more valuable and maintainable. This amendment clarifies testing philosophy to focus on what matters: does the feature work correctly, not does it have a specific button in a specific place.
-->

# StrivePlanner Constitution

## Core Principles

### I. User Empowerment First

Every interaction on the StrivePlanner website MUST help users feel more capable of achieving their goals in life. This principle governs all features—blog posts, comments, email newsletters, community forums, and app downloads.

**Requirements**:
- User flows MUST reduce friction and eliminate confusion
- Language MUST be encouraging and motivating, never condescending or overwhelming
- Features MUST help users define what they want from life and provide actionable paths to get it
- Every piece of content (blog, email, comment) MUST provide tangible value toward goal achievement
- Design and interactions MUST reinforce user confidence and capability

**Rationale**: StrivePlanner exists to help people live more fulfilling lives by achieving their goals. If a feature doesn't empower users, it doesn't belong in the product.

### II. Jony Ive Design Philosophy (NON-NEGOTIABLE)

All UI/UX design MUST follow Jony Ive-inspired principles: radical simplicity, generous whitespace, soft rounded elements, calming colors, and intuitive interactions.

**Requirements**:
- Design MUST feel inevitable and fade into the background
- Whitespace MUST be generous—never cramped or cluttered
- Elements MUST use soft, rounded corners (avoid sharp edges)
- Color palette MUST be calming and non-aggressive
- Interactions MUST be intuitive—users should never need instructions
- Visual hierarchy MUST be clear through typography and spacing, not through color or decoration
- Every element MUST justify its existence—remove anything unnecessary

**Rationale**: Design should support the user's journey, not distract from it. By making the interface feel inevitable and calming, users can focus on their goals rather than fighting the interface.

### III. Test-First Development (NON-NEGOTIABLE)

TDD is mandatory for all features. Tests MUST be written, reviewed by stakeholders if applicable, confirmed to fail, and only then can implementation begin.

**Requirements**:
- Tests MUST be written before implementation code
- Tests MUST fail initially (Red phase)
- Implementation makes tests pass (Green phase)
- Code MUST be refactored while maintaining passing tests (Refactor phase)
- Red-Green-Refactor cycle strictly enforced
- No feature is complete without tests
- Tests MUST verify functional behavior, NOT UI presentation
- Tests MUST NOT check for specific UI elements, styling, or layout
- Tests MUST focus on: data flow, API contracts, business logic, state changes
- Tests MAY verify HTTP response codes and data structures, NOT HTML content

**UI Testing Exclusions**:
- NEVER test for element existence (e.g., "button with class X exists")
- NEVER test for specific text rendering or styling
- NEVER test for CSS properties or layout positioning
- NEVER test for specific HTML structure or tag presence
- Focus instead on: Does the feature work? Does data flow correctly? Do APIs respond properly?

**Rationale**: TDD ensures code quality, prevents regressions, documents intended behavior, and reduces debugging time. UI tests are brittle and break with design changes even when functionality is correct. Functional tests provide lasting value by verifying behavior, not implementation details.

### IV. Phoenix Conventions & Contexts

Code MUST follow Phoenix and Elixir conventions with clear context boundaries that organize related functionality.

**Requirements**:
- Phoenix Contexts MUST define clear domain boundaries (e.g., `Accounts`, `Blog`, `Community`)
- Each context MUST expose a well-defined public API that hides implementation details
- Contexts MUST NOT directly call other contexts' private functions
- Ecto schemas MUST live within their respective contexts
- Business logic MUST reside in context modules, not controllers or LiveViews
- Controllers and LiveViews MUST be thin, delegating to contexts
- Follow Phoenix's `lib/strive_planner/` (business logic) and `lib/strive_planner_web/` (web interface) separation
- Database queries MUST be composed using Ecto.Query in context modules
- Changesets MUST be created in schema modules or context modules, never in controllers/LiveViews
- Use Phoenix generators (`mix phx.gen.*`) as a starting point, then refine

**Rationale**: Phoenix's context-based architecture provides excellent separation of concerns without the overhead of clean architecture layers. Contexts give us clear boundaries, testability, and maintainability while embracing Elixir and Phoenix conventions that the ecosystem is built around.

### V. Content-Driven Experience

Every blog post MUST teach a short principle with a clear promise that helps users achieve their goals. Content quality directly impacts user empowerment.

**Requirements**:
- Blog posts MUST be concise and focused on one principle
- Each post MUST include a clear, achievable promise
- Content tone MUST be encouraging and motivating
- Blog content MUST integrate seamlessly with comments, emails, and forum discussions
- Newsletter emails MUST maintain the same empowering tone and value
- Community forum MUST facilitate meaningful connections and mutual support

**Rationale**: Content is the primary vehicle for delivering value to users. High-quality, focused content with clear promises helps users take concrete steps toward their goals.

## Technology Standards

**Framework**: Phoenix (Elixir)
- Phoenix LiveView for interactive UI components
- Ecto for database interactions
- Standard Phoenix project structure (`lib/strive_planner/` and `lib/strive_planner_web/`)
- Phoenix Contexts for domain organization

**Testing**:
- ExUnit for all tests
- Test organization follows Phoenix conventions:
  - `test/strive_planner/` for context tests (business logic)
  - `test/strive_planner_web/` for controller, LiveView, and channel tests
  - `test/support/` for test helpers and fixtures
- Tests MUST run automatically in CI/CD pipeline
- Tests focus on functional behavior, not UI presentation

**Code Quality**:
- Credo for static analysis
- Formatter configured and enforced
- Mix aliases for common tasks (e.g., `mix precommit`)

**Dependencies**:
- Prefer standard library and Phoenix ecosystem solutions
- `:req` library for HTTP requests (avoid `:httpoison`, `:tesla`, `:httpc`)
- Minimize external dependencies to reduce complexity

## Design Standards

**Visual Design**:
- Generous whitespace (minimum 2-3x standard spacing)
- Soft rounded corners on all interactive elements (border-radius: 12px minimum)
- Calming color palette (earth tones, soft blues, warm neutrals)
- Typography hierarchy using size and weight, not color
- Maximum 2-3 font weights per typeface

**Interaction Design**:
- Micro-interactions MUST feel responsive (<100ms feedback)
- Navigation MUST be intuitive without labels where possible
- Forms MUST validate inline with encouraging error messages
- Loading states MUST be subtle and non-intrusive
- Animations MUST be purposeful, never decorative

**Accessibility**:
- WCAG 2.1 AA compliance minimum
- Keyboard navigation fully supported
- Screen reader compatibility verified
- Color contrast ratios meet accessibility standards

## Content Quality Standards

**Blog Posts**:
- Length: 800-1500 words ideal
- Structure: Introduction → Principle → Examples → Promise → Action Steps
- Tone: Warm, encouraging, concrete (avoid vague motivational platitudes)
- SEO optimized but human-first

**Community Interactions**:
- Comments MUST be moderated for encouragement and constructive support
- Forum discussions MUST maintain respectful, goal-oriented focus
- Newsletter emails MUST provide value in every send (no filler content)

**Language Guidelines**:
- Use "you" to directly address the user
- Use active voice and concrete verbs
- Avoid jargon and unnecessary complexity
- Frame challenges as opportunities for growth
- Celebrate small wins and progress

## Governance

This constitution supersedes all other development practices and design decisions. Any feature, design, or code that conflicts with these principles MUST be rejected or revised.

**Amendment Process**:
1. Proposed amendments MUST be documented with rationale
2. Amendments require team approval (or project owner approval for solo projects)
3. Version number MUST be incremented according to semantic versioning
4. All dependent templates and documentation MUST be updated to reflect amendments
5. Migration plan MUST be created for breaking changes

**Compliance Verification**:
- All PRs MUST verify compliance with constitution principles
- Code reviews MUST explicitly check for context boundary violations
- Design reviews MUST explicitly check for Jony Ive principle adherence
- Any complexity introduction MUST be justified against simplicity principles

**Versioning**:
- MAJOR: Backward-incompatible changes to core principles or governance
- MINOR: New principles added or existing principles materially expanded
- PATCH: Clarifications, wording improvements, or non-semantic refinements

**Runtime Guidance**:
- See CLAUDE.md for development workflow and Phoenix/Elixir-specific patterns
- This constitution defines "what" and "why"; CLAUDE.md provides "how"

**Version**: 2.1.0 | **Ratified**: 2025-01-23 | **Last Amended**: 2025-10-24
