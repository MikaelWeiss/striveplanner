# Data Model: Blog Post Management and Mailing List

**Feature**: 001-blog-mailing
**Date**: 2025-10-24

## Overview

This document defines the data entities, relationships, validation rules, and state transitions for the blog and mailing list feature. The data model extends existing schemas (BlogPost, Subscriber) without introducing new tables.

## Entities

### BlogPost (Existing Schema - Modified)

**Purpose**: Represents a blog article with publication and email delivery state

**Schema Location**: `lib/strive_planner/blog/blog_post.ex`

**Fields**:

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | integer | auto | - | Primary key |
| title | string | yes | - | Blog post title |
| slug | string | yes | auto | URL-friendly identifier (auto-generated from title) |
| content | string | yes | - | Markdown content of the post |
| excerpt | string | no | - | Short summary for listings |
| tags | array(string) | no | [] | Topic tags for categorization |
| status | string | yes | "draft" | Publication status: `draft`, `scheduled`, `published` |
| published_at | datetime | no | - | When the post was published to the website |
| scheduled_email_for | datetime | no | - | **NEW**: When to send email to subscribers (independent of published_at) |
| email_sent_at | datetime | no | - | **EXISTING**: When email was actually sent |
| email_recipient_count | integer | no | 0 | **EXISTING**: How many subscribers received the email |
| sent_to_subscribers | boolean | no | false | **EXISTING**: Whether email has been sent |
| featured_image | string | no | - | URL to featured image |
| images | array(string) | no | [] | URLs to additional images |
| meta_description | string | no | - | SEO meta description |
| view_count | integer | no | 0 | Number of views |
| author_id | integer | no | - | Foreign key to User |
| inserted_at | datetime | auto | now() | Creation timestamp |
| updated_at | datetime | auto | now() | Last update timestamp |

**Relationships**:
- `belongs_to :author, StrivePlanner.Accounts.User`
- `has_many :comments, StrivePlanner.Blog.Comment`

**Validation Rules**:
- `title`: Required, minimum 3 characters
- `content`: Required, minimum 10 characters
- `slug`: Required, unique, format: `/^[a-z0-9-]+$/` (lowercase alphanumeric with dashes)
- `status`: Must be one of: `draft`, `scheduled`, `published`
- `scheduled_email_for`: Must be in the future if set
- `published_at`: Set automatically when status changes to `published` (if nil)

**Indexes**:
- Existing: `slug` (unique), `status`, `published_at`
- **NEW**: Composite index on `(scheduled_email_for, sent_to_subscribers)` for efficient scheduled email queries

**State Transitions** (see State Machine section below)

---

### Subscriber (Existing Schema - Modified)

**Purpose**: Represents a newsletter subscriber with verification and subscription state

**Schema Location**: `lib/strive_planner/newsletter/subscriber.ex`

**Fields**:

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| id | integer | auto | - | Primary key |
| email | string | yes | - | Subscriber email address |
| verified | boolean | yes | false | Whether email has been verified via double opt-in |
| subscription_status | string | **NEW** | "subscribed" | Subscription state: `subscribed`, `unsubscribed` |
| verification_token | string | no | - | Token for email verification |
| verification_token_expires_at | datetime | no | - | When verification token expires |
| inserted_at | datetime | auto | now() | Creation timestamp |
| updated_at | datetime | auto | now() | Last update timestamp |

**Relationships**: None

**Validation Rules**:
- `email`: Required, unique, format: `/^[^\s]+@[^\s]+$/` (basic email validation)
- `subscription_status`: Must be one of: `subscribed`, `unsubscribed`
- `verified`: Boolean, defaults to false

**Indexes**:
- Existing: `email` (unique)
- **NEW**: `subscription_status` for efficient filtering
- **NEW**: Composite index on `(verified, subscription_status)` for email delivery queries

**State Transitions**:
1. New subscriber → `subscribed` (unverified)
2. Click verification link → `subscribed` (verified)
3. Click unsubscribe link → `unsubscribed` (verified/unverified)
4. Admin create → `subscribed` (can set verified manually)

---

### EmailDeliveryRecord (Implicit - No New Table)

**Purpose**: Track email delivery metadata (stored in BlogPost fields)

**Implementation**: Data stored directly on BlogPost:
- `email_sent_at`: Timestamp of delivery
- `email_recipient_count`: Number of recipients
- `sent_to_subscribers`: Boolean flag

**Rationale**: Simple one-to-one relationship (one blog post = one email delivery). No need for separate table. Future enhancement could extract to separate table if detailed delivery tracking needed (opens, clicks, bounces).

---

## State Machines

### BlogPost Publication State

**States**: `draft`, `published`

**Transitions**:

```
┌─────────┐
│  draft  │
└────┬────┘
     │ publish()
     │ - Set status = "published"
     │ - Set published_at = now() if nil
     │ - Keep scheduled_email_for unchanged
     ▼
┌───────────┐
│ published │
└─────┬─────┘
      │ unpublish()
      │ - Set status = "draft"
      │ - Keep published_at (history)
      │ - Cancel scheduled email (if exists)
      ▼
┌─────────┐
│  draft  │
└─────────┘
```

**Business Rules**:
- Publishing does NOT automatically schedule email
- Unpublishing DOES cancel scheduled email
- `published_at` is never cleared (preserves history)
- Email scheduling is independent of publication state

### BlogPost Email Delivery State

**States**: Not scheduled, Scheduled, Sent

**Transitions**:

```
┌──────────────┐
│ Not scheduled│ (scheduled_email_for = nil)
└──────┬───────┘
       │ schedule_email(datetime)
       │ - Set scheduled_email_for = datetime
       │ - Enqueue Oban job for datetime
       ▼
┌───────────┐
│ Scheduled │ (scheduled_email_for != nil, sent_to_subscribers = false)
└─────┬─────┘
      │ process_scheduled_email()
      │ - Send emails to verified subscribers
      │ - Set email_sent_at = now()
      │ - Set email_recipient_count = N
      │ - Set sent_to_subscribers = true
      │ - Keep scheduled_email_for (history)
      ▼
┌──────┐
│ Sent │ (sent_to_subscribers = true)
└──────┘
```

**Cancellation**:
```
Scheduled ──cancel_scheduled_email()──> Not scheduled
  │ - Set scheduled_email_for = nil
  │ - Delete Oban job
```

**Business Rules**:
- Can schedule email for draft or published posts
- Scheduled time must be in future
- Unpublishing cancels scheduled email
- Changing schedule date cancels old job, creates new job
- Can only send once (sent_to_subscribers prevents double-send)

### Subscriber Status State

**States**: `subscribed` (unverified), `subscribed` (verified), `unsubscribed`

**Transitions**:

```
┌────────────────┐
│ subscribed     │ (verified = false)
│ (unverified)   │
└────┬───────────┘
     │ verify()
     │ - Set verified = true
     ▼
┌────────────────┐
│ subscribed     │ (verified = true)
│ (verified)     │
└────┬───────────┘
     │ unsubscribe()
     │ - Set subscription_status = "unsubscribed"
     │ - Keep verified = true (history)
     ▼
┌──────────────┐
│ unsubscribed │ (verified can be true/false)
└──────────────┘
```

**Business Rules**:
- Subscribers start as `subscribed` (unverified)
- Only verified subscribers receive emails
- Unsubscribed subscribers NEVER receive emails (regardless of verified status)
- Verification status is preserved when unsubscribing

---

## Queries

### Critical Queries

**1. Get posts scheduled for email (Oban worker)**

```elixir
from p in BlogPost,
  where: p.scheduled_email_for <= ^DateTime.utc_now(),
  where: p.sent_to_subscribers == false,
  where: not is_nil(p.scheduled_email_for)
```

**2. Get verified, subscribed subscribers (email delivery)**

```elixir
from s in Subscriber,
  where: s.verified == true,
  where: s.subscription_status == "subscribed"
```

**3. Get posts with email status for admin sidebar**

```elixir
from p in BlogPost,
  where: not is_nil(p.scheduled_email_for) or p.sent_to_subscribers == true,
  order_by: [desc: p.updated_at]
```

---

## Data Integrity Rules

**BlogPost**:
- If `sent_to_subscribers = true`, then `email_sent_at` must be set
- If `email_sent_at` is set, then `email_recipient_count` should be > 0
- If `status = "published"`, then `published_at` should be set
- `slug` must be globally unique

**Subscriber**:
- `email` must be globally unique
- If `verified = true`, then `verification_token` can be null
- `subscription_status` can only be `subscribed` or `unsubscribed`

---

## Database Migrations

### Migration 1: Add subscription_status to subscribers

**File**: `priv/repo/migrations/YYYYMMDDHHMMSS_add_subscription_status_to_subscribers.exs`

```elixir
defmodule StrivePlanner.Repo.Migrations.AddSubscriptionStatusToSubscribers do
  use Ecto.Migration

  def change do
    alter table(:subscribers) do
      add :subscription_status, :string, default: "subscribed", null: false
    end

    create index(:subscribers, [:subscription_status])
    create index(:subscribers, [:verified, :subscription_status])
  end
end
```

### Migration 2: Add index for scheduled emails

**File**: `priv/repo/migrations/YYYYMMDDHHMMSS_add_scheduled_email_index_to_blog_posts.exs`

```elixir
defmodule StrivePlanner.Repo.Migrations.AddScheduledEmailIndexToBlogPosts do
  use Ecto.Migration

  def change do
    create index(:blog_posts, [:scheduled_email_for, :sent_to_subscribers])
  end
end
```

---

## Summary

**Entities Modified**: 2 (BlogPost, Subscriber)
**New Entities**: 0
**New Fields**: 1 (subscription_status on Subscriber)
**New Indexes**: 3
**State Machines**: 3 (BlogPost publication, BlogPost email delivery, Subscriber status)

All data changes extend existing schemas. No new tables required. Data model supports all functional requirements from spec.md.
