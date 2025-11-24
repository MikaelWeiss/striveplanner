# Implementation Plan: Blog Post Management and Mailing List

**Branch**: `001-blog-mailing` | **Date**: 2025-10-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-blog-mailing/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Extend the existing Blog and Newsletter contexts to support full blog post lifecycle management (draft/published/unpublished states) with independent email scheduling. Admins can publish blog posts to the website without immediately emailing subscribers, then schedule email delivery for a future date. The system will display email status in the admin sidebar, manage subscriber lists with verification/subscription status, and provide compliant unsubscribe functionality. This feature separates web publication from email marketing timing while maintaining email compliance (CAN-SPAM, GDPR).

## Technical Context

**Language/Version**: Elixir 1.15+
**Framework**: Phoenix 1.8.0
**Primary Dependencies**: Phoenix LiveView 1.1.0, Ecto 3.13, Swoosh 1.16 (email), Req 0.5 (HTTP), Earmark 1.4 (markdown)
**Storage**: PostgreSQL (via Ecto)
**Testing**: ExUnit (built-in), Phoenix.LiveViewTest
**Target Platform**: Web (server-side rendered LiveView)
**Project Type**: Web application (Phoenix)
**Performance Goals**: Admin actions under 2 seconds, email delivery within 5 minutes of scheduled time, support 10k+ subscribers
**Constraints**: Email compliance (CAN-SPAM, GDPR), 99% email delivery reliability, instant UI transitions (<1s)
**Scale/Scope**: Single admin user initially, 10k+ newsletter subscribers, moderate blog posting frequency (1-5 posts/week)

**Existing Infrastructure**:
- Blog context already exists with BlogPost schema (has `scheduled_email_for` and `email_sent_at` fields)
- Newsletter context already exists with Subscriber schema (has `verified` boolean field)
- Email module exists for sending emails via Swoosh
- Admin authentication via Accounts context
- LiveView-based admin interface exists

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The following checks ensure alignment with the StrivePlanner Constitution (v2.1.0):

### Principle I: User Empowerment First
- [x] Feature reduces friction and eliminates confusion in user flows
  - *Admin can manage blog posts and email scheduling in one place*
  - *Subscribers can unsubscribe with a single click*
- [x] Language and UI elements are encouraging and motivating
  - *Unsubscribe page explains action without guilt-tripping*
  - *Admin UI shows clear status indicators (scheduled, sent)*
- [x] Feature helps users define goals and provides actionable paths
  - *Blog posts continue to provide goal-achievement content*
  - *Email delivery ensures users receive actionable advice*
- [x] Content provides tangible value toward goal achievement
  - *Feature enables timely delivery of empowering blog content*

### Principle II: Jony Ive Design Philosophy
- [x] Design feels inevitable and fades into background
  - *Email scheduling integrated naturally into blog post form*
  - *Status indicators visible but not intrusive in sidebar*
- [x] Whitespace is generous (2-3x standard spacing minimum)
  - *Following existing admin interface patterns*
- [x] Interactive elements use soft rounded corners (12px+ border-radius)
  - *Consistent with existing StrivePlanner design system*
- [x] Color palette is calming (earth tones, soft blues, warm neutrals)
  - *Using existing palette for status indicators*
- [x] Interactions are intuitive without requiring instructions
  - *Date picker for scheduling, simple toggle for draft/publish*
- [x] Visual hierarchy through typography/spacing, not color/decoration
  - *Status info uses typography hierarchy in sidebar*
- [x] Every element justifies its existence
  - *Only essential fields shown: publish status, schedule date, subscriber management*

### Principle III: Test-First Development
- [x] Tests will be written before implementation
  - *TDD workflow planned in tasks phase*
- [x] TDD Red-Green-Refactor cycle planned
  - *Each user story will follow Red-Green-Refactor*
- [x] Test categories identified (context tests, API tests, etc.)
  - *Context tests for Blog/Newsletter, LiveView tests for admin UI*
- [x] Tests focus on functional behavior, NOT UI presentation
  - *Tests verify: blog post state transitions, email scheduling logic, unsubscribe flow*
- [x] Tests verify data flow, API contracts, and business logic
  - *Tests check: scheduled emails sent at correct time, only verified subscribers receive emails*

### Principle IV: Phoenix Conventions & Contexts
- [x] Phoenix Contexts define clear domain boundaries
  - *Blog context: blog post management and email scheduling*
  - *Newsletter context: subscriber management and unsubscribe*
- [x] Each context exposes well-defined public API
  - *Blog: create/update/publish/unpublish/schedule_email functions*
  - *Newsletter: list/create/update/delete/unsubscribe subscriber functions*
- [x] Contexts do not call other contexts' private functions
  - *Blog context calls Newsletter public API for subscriber list*
- [x] Business logic resides in contexts, not controllers/LiveViews
  - *Unpublish logic (cancel scheduled email) in Blog context*
  - *Email sending logic in Blog context*
- [x] Follows `lib/strive_planner/` (business) and `lib/strive_planner_web/` (web) separation
  - *Contexts in lib/strive_planner/, LiveViews in lib/strive_planner_web/*
- [x] Ecto schemas live within their respective contexts
  - *BlogPost in Blog context, Subscriber in Newsletter context*
- [x] Database queries composed in context modules using Ecto.Query
  - *Query scheduled posts, verified subscribers via Ecto.Query*
- [x] Changesets created in schema/context modules, not controllers/LiveViews
  - *BlogPost.changeset, Subscriber.changeset in schemas*

### Principle V: Content-Driven Experience
- [x] Blog posts are concise and focused on one principle
  - *Feature does not change blog post content requirements*
- [x] Content has clear, achievable promise
  - *Feature does not change blog post structure*
- [x] Tone is encouraging and motivating
  - *Unsubscribe confirmation message maintains encouraging tone*
- [x] Community interactions facilitate meaningful support
  - *Email delivery ensures community receives motivational content*

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
# Phoenix Project Structure (StrivePlanner)
lib/strive_planner/
├── blog/                         # Blog context (existing, to be extended)
│   ├── blog_post.ex             # Existing schema - add subscription_status field
│   └── comment.ex               # Existing - no changes
├── blog.ex                       # Existing context - extend with new functions
├── newsletter/                   # Newsletter context (existing, to be extended)
│   └── subscriber.ex            # Existing schema - add subscription_status enum
├── newsletter.ex                 # Existing context - extend with subscriber CRUD
├── email.ex                      # Existing - extend with unsubscribe email template
└── application.ex                # May need scheduled job supervisor

lib/strive_planner_web/
├── controllers/
│   └── newsletter/               # NEW: Newsletter controllers
│       └── unsubscribe_controller.ex  # Handles unsubscribe link clicks
├── live/
│   └── admin/                    # Existing admin LiveViews
│       ├── blog_post_live/       # Existing - extend with email scheduling
│       │   ├── index.ex         # List with sidebar status indicators
│       │   ├── show.ex          # Show with email status
│       │   └── form_component.ex # Add scheduled_email_for field
│       └── subscriber_live/      # NEW: Subscriber management LiveViews
│           ├── index.ex         # List all subscribers with status
│           ├── show.ex          # Show subscriber details
│           └── form_component.ex # Create/edit subscribers
├── components/
│   ├── core_components.ex       # Existing - no changes
│   └── admin_components.ex      # Extend with email status badge component
└── router.ex                     # Add subscriber management routes, unsubscribe route

test/strive_planner/
├── blog/                         # Existing context tests
│   └── blog_test.exs            # Extend with publish/unpublish/schedule tests
└── newsletter/                   # Existing context tests
    └── newsletter_test.exs      # Extend with subscriber CRUD tests

test/strive_planner_web/
├── controllers/
│   └── newsletter/               # NEW: Unsubscribe controller tests
│       └── unsubscribe_controller_test.exs
└── live/
    └── admin/                    # Existing LiveView tests
        ├── blog_post_live_test.exs  # Extend with email scheduling tests
        └── subscriber_live_test.exs # NEW: Subscriber management tests

test/support/
├── fixtures/
│   ├── blog_fixtures.ex         # Existing - extend with scheduled post fixtures
│   └── newsletter_fixtures.ex   # Existing - extend with subscriber fixtures
├── conn_case.ex                  # Existing
└── data_case.ex                  # Existing

priv/repo/migrations/
└── YYYYMMDDHHMMSS_add_subscription_status_to_subscribers.exs  # NEW migration
```

**Structure Decision**:
- **Blog context** (`StrivePlanner.Blog`): Owns blog post lifecycle (draft/published/unpublished) and email scheduling logic. Extended with `publish_post/1`, `unpublish_post/1`, and `process_scheduled_emails/0` functions.
- **Newsletter context** (`StrivePlanner.Newsletter`): Owns subscriber management and unsubscribe flow. Extended with full CRUD functions for subscribers and `unsubscribe/1` function.
- **Email module** (`StrivePlanner.Email`): Handles email template generation. Extended with unsubscribe link generation and blog post notification template.
- **Admin LiveViews**: Manage blog posts and subscribers with status indicators in sidebar.
- **Public unsubscribe**: Simple controller-based page (not LiveView) for unsubscribe confirmation.

**Key Design Decisions**:
- Subscription status will be enum: `subscribed`, `unsubscribed` (verification status remains separate boolean)
- Scheduled email processing will use Oban (background job processor) or GenServer with periodic timer
- Unsubscribe tokens will be signed with Phoenix.Token for security
- Admin sidebar will query posts with scheduled/sent status for display

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitutional violations. All checks passed. Feature extends existing Phoenix contexts following established patterns, maintains clean separation of concerns, and aligns with all constitution principles.
