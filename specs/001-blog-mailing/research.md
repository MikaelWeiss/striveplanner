# Research & Design Decisions: Blog Post Management and Mailing List

**Feature**: 001-blog-mailing
**Date**: 2025-10-24
**Status**: Complete

## Overview

This document consolidates research findings and design decisions for extending the blog and newsletter system with full lifecycle management, email scheduling, and subscriber management capabilities.

## Key Research Areas

### 1. Scheduled Job Processing

**Decision**: Use Oban for background job processing

**Rationale**:
- Oban is the de facto standard for background jobs in Phoenix/Elixir
- Provides reliable scheduling with retry logic and failure handling
- Persists jobs in PostgreSQL (already using Postgres)
- Better than GenServer + timer for production reliability
- Handles system downtime gracefully (jobs queued and processed when system restarts)
- Built-in telemetry and monitoring

**Alternatives Considered**:
- **GenServer with `:timer.send_interval/2`**: Simple but unreliable across restarts, no retry logic, loses jobs if system crashes
- **Quantum**: Cron-like scheduler, but overkill for single scheduled task type
- **Plain Task**: No persistence, no retry, not suitable for critical email delivery

**Implementation**:
- Add Oban dependency to mix.exs
- Create `StrivePlanner.Workers.EmailScheduler` worker
- Configure Oban in application.ex with single queue
- Schedule job when `scheduled_email_for` is set on blog post
- Cancel job when post is unpublished or scheduled date changed

### 2. Subscription Status Management

**Decision**: Add `subscription_status` enum field to Subscriber schema

**Rationale**:
- Clearer than boolean flags (`subscribed?`, `unsubscribed?`)
- Allows future expansion (e.g., `pending`, `bounced`, `complained`)
- Single source of truth for subscription state
- Aligns with email marketing best practices

**Alternatives Considered**:
- **Boolean `subscribed` field**: Too limited, doesn't capture full lifecycle
- **Separate `unsubscribed_at` timestamp**: Requires multiple fields, more complex queries
- **Soft delete**: Loses subscriber history, complicates re-subscription

**Implementation**:
- Migration: Add `subscription_status` enum column with values: `subscribed`, `unsubscribed`
- Default: `subscribed` for new subscribers
- Update queries to filter by `subscription_status = 'subscribed' AND verified = true`

### 3. Unsubscribe Token Security

**Decision**: Use Phoenix.Token for signed unsubscribe links

**Rationale**:
- Built into Phoenix, no additional dependencies
- Cryptographically signed, prevents tampering
- Can set expiration (though unsubscribe links typically don't expire)
- Generates URL-safe tokens
- Standard Phoenix pattern for secure tokens

**Alternatives Considered**:
- **UUID in database**: Requires extra table/column, database lookup on every unsubscribe
- **Signed JWT**: External dependency (jose/joken), overkill for simple use case
- **HMAC signature**: Manual implementation, reinventing Phoenix.Token

**Implementation**:
- Generate token: `Phoenix.Token.sign(conn, "unsubscribe", subscriber.id)`
- Verify token: `Phoenix.Token.verify(conn, "unsubscribe", token, max_age: :infinity)`
- Include token in unsubscribe URL: `/unsubscribe?token=#{token}`

### 4. Blog Post State Transitions

**Decision**: Use explicit status field with validation

**Current states in BlogPost schema**: `draft`, `scheduled`, `published`

**Additional logic needed**:
- Unpublish action: Changes `published` → `draft`, cancels scheduled email
- Publish action: Changes `draft` → `published`, sets `published_at` if nil
- Schedule email: Sets `scheduled_email_for` datetime (can be done in any state)

**State transition rules**:
1. Draft → Published: Allowed, sets published_at
2. Published → Draft (Unpublish): Allowed, cancels scheduled email
3. Any → Scheduled email: Allowed if published or draft
4. Scheduled → Draft: Cancels scheduled email

**Rationale**:
- Simple state machine with clear transitions
- Existing `status` field already supports these states
- No complex workflow engine needed

### 5. Email Compliance (CAN-SPAM, GDPR)

**Decision**: Include required elements in email template

**Required elements**:
- Physical mailing address (StrivePlanner business address)
- Clear "Unsubscribe" link
- Accurate "From" name and email
- Clear subject line (blog post title)
- Honor unsubscribe requests within 10 days (instant in our case)

**Implementation**:
- Email footer template includes:
  - Business address
  - One-click unsubscribe link
  - Privacy policy link
  - Company name
- Unsubscribe immediately updates subscription_status
- No emails sent to unsubscribed users

### 6. Email Delivery Filtering

**Decision**: Multi-condition filter for email recipients

**Conditions for receiving emails**:
1. `verified = true` (email verified via double opt-in)
2. `subscription_status = 'subscribed'` (not unsubscribed)

**Query**:
```elixir
from s in Subscriber,
  where: s.verified == true,
  where: s.subscription_status == "subscribed"
```

**Rationale**:
- Prevents sending to unverified emails (reduces bounces)
- Respects unsubscribe requests (legal compliance)
- Clear, simple query logic

### 7. Admin Sidebar Status Indicators

**Decision**: Query scheduled/sent posts on mount, display badges

**Status indicators**:
- **Scheduled**: Orange badge with date (future `scheduled_email_for`)
- **Sent**: Green badge with date (`email_sent_at` populated)
- **No status**: No email indicator shown

**Implementation**:
- LiveView `mount/3`: Query posts with email status
- Helper function: `email_status_badge(post)` returns badge component
- Badge component uses existing Jony Ive design (rounded, calming colors)

**Rationale**:
- Admin sees status at a glance without opening posts
- Consistent with existing admin UI patterns
- Minimal database queries (loaded once on mount)

### 8. Subscriber Management CRUD

**Decision**: Standard Phoenix LiveView CRUD pattern

**Operations**:
- Index: List all subscribers with status, verification, dates
- Show: Display subscriber details with email history
- Create: Add new subscriber (auto-generates verification email)
- Update: Edit subscriber email
- Delete: Remove subscriber from database

**Implementation**:
- Generate with: `mix phx.gen.live Newsletter Subscriber subscribers --no-schema`
- Customize generated LiveViews to show verification/subscription status
- Add filters: verified/unverified, subscribed/unsubscribed

**Rationale**:
- Standard Phoenix patterns (familiar to developers)
- Full CRUD gives admin control over subscriber data
- Supports manual additions for imported lists

### 9. Unsubscribe Confirmation Page

**Decision**: Simple controller-rendered page (not LiveView)

**Rationale**:
- No interactivity needed after unsubscribe
- Faster page load (no LiveView overhead)
- Simple message: "You've been unsubscribed"
- Consistent with minimalist design philosophy

**Implementation**:
- `UnsubscribeController.unsubscribe/2` action
- Verifies token, updates subscription_status
- Renders `unsubscribe.html.heex` template with confirmation message
- Template uses encouraging language: "You won't receive emails from us anymore. We understand."

## Technology Stack Summary

**New Dependencies**:
- Oban 2.18+ (background job processing)

**Existing Dependencies (utilized)**:
- Phoenix.Token (unsubscribe link security)
- Ecto (database migrations, queries)
- Swoosh (email sending)

## Database Changes

**Migration 1**: Add subscription_status to subscribers

```sql
ALTER TABLE subscribers
ADD COLUMN subscription_status VARCHAR(20) DEFAULT 'subscribed' NOT NULL;

CREATE INDEX idx_subscribers_subscription_status ON subscribers(subscription_status);
```

**No migration needed for blog_posts**: Schema already has `scheduled_email_for` and `email_sent_at` fields

## Configuration Decisions

**Oban Configuration**:
- Single queue: `:emails`
- Worker module: `StrivePlanner.Workers.EmailScheduler`
- Job scheduling: On blog post save with `scheduled_email_for`
- Job cancellation: When post unpublished or date changed

**Email Configuration**:
- From address: Configured in `config/runtime.exs` (existing)
- Unsubscribe token salt: `"unsubscribe"` (hardcoded, safe)
- Email template: Extend existing `StrivePlanner.Email` module

## Open Questions & Resolutions

**Q: What happens if scheduled time is in the past?**
A: Validation in changeset prevents setting past dates. If somehow saved, Oban processes immediately.

**Q: How to handle duplicate email addresses?**
A: Unique constraint on `subscribers.email` prevents duplicates at database level.

**Q: What if subscriber clicks unsubscribe multiple times?**
A: Idempotent operation - updates subscription_status even if already unsubscribed. No error shown.

**Q: Can a subscriber re-subscribe after unsubscribing?**
A: Not in this feature scope. Future enhancement: public subscribe form would change status back to `subscribed`.

**Q: How to test scheduled email sending?**
A: Oban provides test helpers to assert jobs enqueued. Can manually trigger worker in tests with `perform_job/2`.

## Best Practices Applied

**Phoenix Conventions**:
- Contexts for business logic (Blog, Newsletter)
- Thin controllers and LiveViews
- Schemas in context subdirectories
- Changesets validate all data

**Email Marketing**:
- Double opt-in (verified flag)
- One-click unsubscribe
- Clear sender identity
- Compliance with CAN-SPAM/GDPR

**Security**:
- Signed tokens (Phoenix.Token)
- SQL injection prevention (Ecto parameterized queries)
- XSS protection (HEEx auto-escaping)

**Testing**:
- Context tests for business logic
- LiveView tests for UI interactions (functional, not presentational)
- Controller tests for unsubscribe flow

## Summary

All research complete. No unresolved clarifications. Ready to proceed to Phase 1 (data model and contracts).

Key takeaways:
- Oban for reliable scheduled email delivery
- Phoenix.Token for secure unsubscribe links
- Subscription status enum for clear state management
- Extend existing contexts (no new contexts needed)
- Standard Phoenix patterns throughout
