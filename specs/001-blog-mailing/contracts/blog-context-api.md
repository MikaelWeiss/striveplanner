# Blog Context API Contract

**Context**: `StrivePlanner.Blog`
**Purpose**: Manage blog posts and email scheduling

## Public Functions

### Blog Post CRUD

#### `list_posts/0`
**Purpose**: Get all published posts for public view
**Parameters**: None
**Returns**: `[%BlogPost{}]`
**Side Effects**: None
**Query**: Where status = "published", order by published_at desc

#### `list_all_posts/0`
**Purpose**: Get all posts for admin (includes drafts)
**Parameters**: None
**Returns**: `[%BlogPost{}]`
**Side Effects**: None
**Query**: Order by updated_at desc

#### `get_post/1`
**Purpose**: Get single published post by slug (public)
**Parameters**:
- `slug` (string): URL slug
**Returns**: `{:ok, %BlogPost{}}` | `{:error, :not_found}`
**Side Effects**: None

#### `get_post!/1`
**Purpose**: Get single post by ID (admin)
**Parameters**:
- `id` (integer): BlogPost ID
**Returns**: `%BlogPost{}` | raises Ecto.NoResultsError
**Side Effects**: None

#### `create_post/1`
**Purpose**: Create a new blog post
**Parameters**:
- `attrs` (map): Post attributes (title, content, status, scheduled_email_for, etc.)
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Inserts record in database
- If `scheduled_email_for` is set, enqueues Oban job

**Example**:
```elixir
Blog.create_post(%{
  title: "My Post",
  content: "Post content...",
  status: "draft",
  scheduled_email_for: ~U[2025-10-25 10:00:00Z]
})
```

#### `update_post/2`
**Purpose**: Update existing blog post
**Parameters**:
- `post` (%BlogPost{}): Existing post struct
- `attrs` (map): Attributes to update
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Updates record in database
- If `scheduled_email_for` changes, cancels old job and enqueues new job
- If `scheduled_email_for` set to nil, cancels scheduled job

**Example**:
```elixir
post = Blog.get_post!(123)
Blog.update_post(post, %{scheduled_email_for: ~U[2025-10-26 14:00:00Z]})
```

#### `delete_post/1`
**Purpose**: Delete a blog post
**Parameters**:
- `post` (%BlogPost{}): Post to delete
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Deletes record from database
- Cancels scheduled email job if exists

#### `change_post/2`
**Purpose**: Get changeset for tracking post changes (for forms)
**Parameters**:
- `post` (%BlogPost{}): Existing post or new post struct
- `attrs` (map, optional): Default {}
**Returns**: `%Ecto.Changeset{}`
**Side Effects**: None

---

### Blog Post Lifecycle

#### `publish_post/1` *(NEW)*
**Purpose**: Publish a draft post (make visible on website)
**Parameters**:
- `post` (%BlogPost{}): Post to publish
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Sets status = "published"
- Sets published_at = now() if nil
- Does NOT schedule email (independent action)

**Business Rules**:
- Can only publish from draft status
- Does not affect scheduled_email_for

**Example**:
```elixir
post = Blog.get_post!(123)
{:ok, published_post} = Blog.publish_post(post)
```

#### `unpublish_post/1` *(NEW)*
**Purpose**: Unpublish a post (remove from website, keep in admin)
**Parameters**:
- `post` (%BlogPost{}): Post to unpublish
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Sets status = "draft"
- Keeps published_at (history)
- Cancels scheduled email job if exists
- Sets scheduled_email_for = nil

**Business Rules**:
- Can only unpublish from published status
- Cancels any pending scheduled email

**Example**:
```elixir
post = Blog.get_post!(123)
{:ok, unpublished_post} = Blog.unpublish_post(post)
# scheduled_email_for is now nil, Oban job cancelled
```

---

### Email Scheduling

#### `schedule_email/2` *(NEW)*
**Purpose**: Schedule email delivery for a post
**Parameters**:
- `post` (%BlogPost{}): Post to schedule
- `scheduled_at` (DateTime): When to send email
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Sets scheduled_email_for = scheduled_at
- Enqueues Oban job for scheduled_at
- Cancels previous scheduled job if exists

**Business Rules**:
- scheduled_at must be in future
- Can schedule for draft or published posts
- Replaces existing schedule if already set

**Example**:
```elixir
post = Blog.get_post!(123)
scheduled_time = DateTime.utc_now() |> DateTime.add(3600, :second) # +1 hour
{:ok, scheduled_post} = Blog.schedule_email(post, scheduled_time)
```

#### `cancel_scheduled_email/1` *(NEW)*
**Purpose**: Cancel a scheduled email
**Parameters**:
- `post` (%BlogPost{}): Post with scheduled email
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Sets scheduled_email_for = nil
- Cancels Oban job

**Example**:
```elixir
post = Blog.get_post!(123)
{:ok, post} = Blog.cancel_scheduled_email(post)
```

#### `process_scheduled_emails/0` *(NEW)*
**Purpose**: Process all posts scheduled for email (called by Oban worker)
**Parameters**: None
**Returns**: `{:ok, count}` where count is number of emails sent
**Side Effects**:
- Queries posts where scheduled_email_for <= now AND sent_to_subscribers = false
- For each post, calls `send_to_subscribers/1`
- Updates post with email_sent_at, email_recipient_count

**Called By**: `StrivePlanner.Workers.EmailScheduler` (Oban worker)

**Example**:
```elixir
# Called automatically by Oban every minute
{:ok, 3} = Blog.process_scheduled_emails()
# 3 posts had scheduled emails sent
```

---

### Email Delivery

#### `send_to_subscribers/1` (Existing - No Changes)
**Purpose**: Send blog post email to all verified subscribers
**Parameters**:
- `post` (%BlogPost{}): Post to send
**Returns**: `{:ok, count}` | `{:error, reason}`
**Side Effects**:
- Queries Newsletter.list_verified_subscribed_subscribers()
- Sends email to each subscriber via Email module
- Updates post: email_sent_at, email_recipient_count, sent_to_subscribers = true

**Business Rules**:
- Only sends to verified AND subscribed subscribers
- Sets sent_to_subscribers = true to prevent double-send
- Records recipient count

---

### Helper Functions

#### `increment_view_count/1` (Existing - No Changes)
**Purpose**: Increment view count for a post
**Parameters**:
- `post` (%BlogPost{}): Post to increment
**Returns**: `{:ok, %BlogPost{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**: Increments view_count by 1

#### `render_markdown/1` (Existing - No Changes)
**Purpose**: Convert markdown content to HTML
**Parameters**:
- `content` (string): Markdown content
**Returns**: string (HTML)
**Side Effects**: None

---

## Private Functions (Internal to Context)

### `enqueue_email_job/1`
**Purpose**: Enqueue Oban job for scheduled email
**Parameters**:
- `post` (%BlogPost{}): Post with scheduled_email_for
**Returns**: `{:ok, Oban.Job.t()}`
**Side Effects**: Creates Oban job

### `cancel_email_job/1`
**Purpose**: Cancel Oban job for post
**Parameters**:
- `post` (%BlogPost{}): Post with scheduled email
**Returns**: `:ok`
**Side Effects**: Deletes Oban job from queue

---

## Usage Examples

### Typical Admin Workflow

```elixir
# 1. Create draft post
{:ok, post} = Blog.create_post(%{
  title: "10 Steps to Better Goals",
  content: "Content here...",
  status: "draft"
})

# 2. Publish post to website
{:ok, post} = Blog.publish_post(post)

# 3. Schedule email for tomorrow 9am
tomorrow_9am = DateTime.utc_now() |> DateTime.add(86400, :second) |> DateTime.truncate(:second)
{:ok, post} = Blog.schedule_email(post, tomorrow_9am)

# 4. Later: unpublish post (cancels scheduled email)
{:ok, post} = Blog.unpublish_post(post)
# scheduled_email_for is now nil
```

### Email Sending Workflow

```elixir
# Oban worker calls this every minute
{:ok, count} = Blog.process_scheduled_emails()

# Internally:
# - Queries posts where scheduled_email_for <= now
# - For each post, gets verified subscribers
# - Sends emails
# - Updates post with sent info
```

---

## Error Cases

| Function | Error | Reason |
|----------|-------|--------|
| `create_post/1` | `{:error, changeset}` | Validation failed (missing title/content, invalid slug, etc.) |
| `update_post/2` | `{:error, changeset}` | Validation failed or scheduled_email_for in past |
| `publish_post/1` | `{:error, changeset}` | Post not in draft status |
| `unpublish_post/1` | `{:error, changeset}` | Post not in published status |
| `schedule_email/2` | `{:error, changeset}` | scheduled_at in past |
| `send_to_subscribers/1` | `{:error, :no_subscribers}` | No verified subscribers found |
| `send_to_subscribers/1` | `{:error, reason}` | Email sending failed |
| `get_post/1` | `{:error, :not_found}` | Post not found or not published |
| `get_post!/1` | raises Ecto.NoResultsError | Post not found |

---

## Context Boundary Rules

**Blog context calls**:
- `Newsletter.list_verified_subscribed_subscribers()` - OK (public API)
- `Email.send_blog_post_to_subscribers/2` - OK (public API)

**Blog context does NOT call**:
- Newsletter private functions
- Direct Subscriber schema access

---

## Testing Expectations

**Context tests** (`test/strive_planner/blog/blog_test.exs`):
- Test each public function
- Test state transitions (publish, unpublish, schedule)
- Test error cases (invalid data, past dates)
- Mock Oban jobs (use Oban.Testing)
- Verify database changes

**LiveView tests** (`test/strive_planner_web/live/admin/blog_post_live_test.exs`):
- Test UI interactions (clicking publish, setting schedule date)
- Test form submission
- Verify functional outcomes (post published, email scheduled)
- Do NOT test HTML structure or element existence
