# Newsletter Context API Contract

**Context**: `StrivePlanner.Newsletter`
**Purpose**: Manage newsletter subscribers and unsubscribe flow

## Public Functions

### Subscriber CRUD

#### `list_subscribers/0` *(NEW)*
**Purpose**: Get all subscribers for admin view
**Parameters**: None
**Returns**: `[%Subscriber{}]`
**Side Effects**: None
**Query**: Order by inserted_at desc

**Example**:
```elixir
subscribers = Newsletter.list_subscribers()
# Returns all subscribers with verification and subscription status
```

#### `list_verified_subscribed_subscribers/0` *(NEW)*
**Purpose**: Get subscribers eligible for emails
**Parameters**: None
**Returns**: `[%Subscriber{}]`
**Side Effects**: None
**Query**: Where verified = true AND subscription_status = "subscribed"

**Example**:
```elixir
recipients = Newsletter.list_verified_subscribed_subscribers()
# Only returns verified, subscribed users
```

#### `get_subscriber!/1` *(NEW)*
**Purpose**: Get single subscriber by ID (admin)
**Parameters**:
- `id` (integer): Subscriber ID
**Returns**: `%Subscriber{}` | raises Ecto.NoResultsError
**Side Effects**: None

#### `get_subscriber_by_email/1` *(NEW)*
**Purpose**: Get subscriber by email address
**Parameters**:
- `email` (string): Email address
**Returns**: `%Subscriber{}` | `nil`
**Side Effects**: None

**Example**:
```elixir
subscriber = Newsletter.get_subscriber_by_email("user@example.com")
```

#### `create_subscriber/1` *(NEW)*
**Purpose**: Create a new subscriber
**Parameters**:
- `attrs` (map): Subscriber attributes (email, verified, subscription_status)
**Returns**: `{:ok, %Subscriber{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**:
- Inserts record in database
- Defaults: verified = false, subscription_status = "subscribed"
- Generates verification token if verified = false

**Business Rules**:
- Email must be unique
- Email must be valid format
- subscription_status defaults to "subscribed"

**Example**:
```elixir
{:ok, subscriber} = Newsletter.create_subscriber(%{
  email: "user@example.com"
})
# subscriber.verified = false
# subscriber.subscription_status = "subscribed"
```

#### `update_subscriber/2` *(NEW)*
**Purpose**: Update existing subscriber
**Parameters**:
- `subscriber` (%Subscriber{}): Existing subscriber struct
- `attrs` (map): Attributes to update
**Returns**: `{:ok, %Subscriber{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**: Updates record in database

**Example**:
```elixir
subscriber = Newsletter.get_subscriber!(123)
{:ok, updated} = Newsletter.update_subscriber(subscriber, %{
  email: "newemail@example.com"
})
```

#### `delete_subscriber/1` *(NEW)*
**Purpose**: Delete a subscriber
**Parameters**:
- `subscriber` (%Subscriber{}): Subscriber to delete
**Returns**: `{:ok, %Subscriber{}}` | `{:error, %Ecto.Changeset{}}`
**Side Effects**: Deletes record from database

**Example**:
```elixir
subscriber = Newsletter.get_subscriber!(123)
{:ok, deleted} = Newsletter.delete_subscriber(subscriber)
```

#### `change_subscriber/2` *(NEW)*
**Purpose**: Get changeset for tracking subscriber changes (for forms)
**Parameters**:
- `subscriber` (%Subscriber{}): Existing subscriber or new subscriber struct
- `attrs` (map, optional): Default {}
**Returns**: `%Ecto.Changeset{}`
**Side Effects**: None

---

### Subscription Management

#### `unsubscribe/1` *(NEW)*
**Purpose**: Unsubscribe a subscriber (via token from email link)
**Parameters**:
- `subscriber_id` (integer): ID from verified token
**Returns**: `{:ok, %Subscriber{}}` | `{:error, :not_found}`
**Side Effects**:
- Sets subscription_status = "unsubscribed"
- Keeps verified status unchanged (history)

**Business Rules**:
- Idempotent - can unsubscribe multiple times
- Does not delete subscriber record
- Preserves verification history

**Example**:
```elixir
# Called from UnsubscribeController after verifying token
{:ok, subscriber} = Newsletter.unsubscribe(subscriber_id)
# subscriber.subscription_status = "unsubscribed"
# subscriber.verified unchanged
```

#### `resubscribe/1` *(Future - Not in this feature)*
**Purpose**: Re-subscribe an unsubscribed user
**Note**: Not implemented in this feature. Future enhancement for public subscribe form.

---

### Verification (Existing - No Changes Expected)

#### `verify_subscriber/1` (Existing)
**Purpose**: Verify subscriber email address
**Parameters**:
- `token` (string): Verification token
**Returns**: `{:ok, %Subscriber{}}` | `{:error, :invalid_token}`
**Side Effects**: Sets verified = true

**Note**: Existing function. No changes needed for this feature.

---

## Private Functions (Internal to Context)

### `generate_verification_token/1`
**Purpose**: Generate verification token for new subscribers
**Parameters**:
- `subscriber` (%Subscriber{}): Subscriber to generate token for
**Returns**: `{token, expiration_datetime}`
**Side Effects**: None (token stored on subscriber record)

---

## Usage Examples

### Admin Creating Subscriber

```elixir
# Create new subscriber (unverified)
{:ok, subscriber} = Newsletter.create_subscriber(%{
  email: "user@example.com"
})

# Admin can manually verify if needed
{:ok, verified} = Newsletter.update_subscriber(subscriber, %{verified: true})
```

### User Unsubscribe Flow

```elixir
# 1. User clicks unsubscribe link in email with token
# 2. UnsubscribeController verifies token and gets subscriber_id
# 3. Call unsubscribe function
{:ok, subscriber} = Newsletter.unsubscribe(subscriber_id)

# Subscriber is now unsubscribed but record persists
```

### Email Delivery Query

```elixir
# Get recipients for blog post email
recipients = Newsletter.list_verified_subscribed_subscribers()

# Send email to each recipient
Enum.each(recipients, fn sub ->
  Email.send_blog_post(post, sub)
end)
```

---

## Error Cases

| Function | Error | Reason |
|----------|-------|--------|
| `create_subscriber/1` | `{:error, changeset}` | Invalid email format, duplicate email, validation failed |
| `update_subscriber/2` | `{:error, changeset}` | Invalid email format, duplicate email |
| `unsubscribe/1` | `{:error, :not_found}` | Subscriber ID not found |
| `get_subscriber!/1` | raises Ecto.NoResultsError | Subscriber not found |

---

## Context Boundary Rules

**Newsletter context calls**:
- No dependencies on other contexts
- Self-contained subscriber management

**Newsletter context does NOT call**:
- Blog context functions
- Direct BlogPost schema access

---

## Data Filters

### Subscription Status Filter

**Query for subscribed only**:
```elixir
from s in Subscriber,
  where: s.subscription_status == "subscribed"
```

**Query for unsubscribed only**:
```elixir
from s in Subscriber,
  where: s.subscription_status == "unsubscribed"
```

**Query for verified, subscribed (email eligible)**:
```elixir
from s in Subscriber,
  where: s.verified == true,
  where: s.subscription_status == "subscribed"
```

---

## Testing Expectations

**Context tests** (`test/strive_planner/newsletter/newsletter_test.exs`):
- Test each CRUD function
- Test unsubscribe flow (idempotency)
- Test email format validation
- Test duplicate email handling
- Verify subscription_status defaults and transitions

**LiveView tests** (`test/strive_planner_web/live/admin/subscriber_live_test.exs`):
- Test creating subscriber via form
- Test updating subscriber email
- Test deleting subscriber
- Test list view shows verification and subscription status
- Do NOT test HTML structure or element existence

**Controller tests** (`test/strive_planner_web/controllers/newsletter/unsubscribe_controller_test.exs`):
- Test valid token unsubscribes user
- Test invalid token shows error
- Test already unsubscribed user (idempotency)
- Verify subscription_status changes to "unsubscribed"

---

## Migration Requirements

**Required migration**: Add `subscription_status` field

```elixir
alter table(:subscribers) do
  add :subscription_status, :string, default: "subscribed", null: false
end

create index(:subscribers, [:subscription_status])
create index(:subscribers, [:verified, :subscription_status])
```

**Data backfill**: Existing subscribers default to "subscribed"
