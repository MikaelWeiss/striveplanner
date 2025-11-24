# Routes API Contract

**Purpose**: Define HTTP routes for blog post management, subscriber management, and unsubscribe flow

## Admin Routes (Protected)

All admin routes require authentication via `:require_authenticated_user` plug.

### Blog Post Management

**Mount path**: `/admin/blog/posts`

| Route | LiveView | Action | Purpose |
|-------|----------|--------|---------|
| GET `/admin/blog/posts` | `BlogPostLive.Index` | `:index` | List all posts with email status |
| GET `/admin/blog/posts/new` | `BlogPostLive.Index` | `:new` | Show new post form (modal/component) |
| GET `/admin/blog/posts/:id/edit` | `BlogPostLive.Index` | `:edit` | Show edit post form (modal/component) |
| GET `/admin/blog/posts/:id` | `BlogPostLive.Show` | `:show` | Show single post with details |

**LiveView Components**:
- `BlogPostLive.FormComponent` - Handles create/edit forms
  - Fields: title, content, status (draft/published), scheduled_email_for
  - Actions: save (create or update), publish, unpublish

**Route Configuration**:
```elixir
scope "/admin", StrivePlannerWeb.Admin, as: :admin do
  pipe_through [:browser, :require_authenticated_user]

  live "/blog/posts", BlogPostLive.Index, :index
  live "/blog/posts/new", BlogPostLive.Index, :new
  live "/blog/posts/:id/edit", BlogPostLive.Index, :edit
  live "/blog/posts/:id", BlogPostLive.Show, :show
end
```

---

### Subscriber Management *(NEW)*

**Mount path**: `/admin/subscribers`

| Route | LiveView | Action | Purpose |
|-------|----------|--------|---------|
| GET `/admin/subscribers` | `SubscriberLive.Index` | `:index` | List all subscribers with status |
| GET `/admin/subscribers/new` | `SubscriberLive.Index` | `:new` | Show new subscriber form (modal/component) |
| GET `/admin/subscribers/:id/edit` | `SubscriberLive.Index` | `:edit` | Show edit subscriber form (modal/component) |
| GET `/admin/subscribers/:id` | `SubscriberLive.Show` | `:show` | Show single subscriber with details |

**LiveView Components**:
- `SubscriberLive.FormComponent` - Handles create/edit forms
  - Fields: email, verified (checkbox), subscription_status (readonly or select)
  - Actions: save (create or update), delete

**Route Configuration**:
```elixir
scope "/admin", StrivePlannerWeb.Admin, as: :admin do
  pipe_through [:browser, :require_authenticated_user]

  live "/subscribers", SubscriberLive.Index, :index
  live "/subscribers/new", SubscriberLive.Index, :new
  live "/subscribers/:id/edit", SubscriberLive.Index, :edit
  live "/subscribers/:id", SubscriberLive.Show, :show
end
```

---

## Public Routes

### Unsubscribe *(NEW)*

**Mount path**: `/unsubscribe`

| Route | Controller | Action | Purpose |
|-------|------------|--------|---------|
| GET `/unsubscribe?token=<token>` | `Newsletter.UnsubscribeController` | `:unsubscribe` | Handle unsubscribe link clicks |

**Controller Action**:
```elixir
def unsubscribe(conn, %{"token" => token}) do
  case Phoenix.Token.verify(conn, "unsubscribe", token, max_age: :infinity) do
    {:ok, subscriber_id} ->
      Newsletter.unsubscribe(subscriber_id)
      render(conn, :unsubscribe, layout: {Layouts, :minimal})

    {:error, _reason} ->
      conn
      |> put_flash(:error, "Invalid unsubscribe link")
      |> redirect(to: ~p"/")
  end
end
```

**Template**: `unsubscribe.html.heex`
- Simple, encouraging message: "You've been unsubscribed"
- No form, no buttons (action already complete)
- Link to homepage
- Minimal layout (no sidebar, nav)

**Route Configuration**:
```elixir
scope "/", StrivePlannerWeb do
  pipe_through :browser

  get "/unsubscribe", Newsletter.UnsubscribeController, :unsubscribe
end
```

---

## LiveView Events

### BlogPostLive.Index

**Events handled**:
- `delete` - Delete a blog post
- `publish` - Publish a draft post
- `unpublish` - Unpublish a published post
- `cancel_schedule` - Cancel scheduled email

**Example event handler**:
```elixir
@impl true
def handle_event("publish", %{"id" => id}, socket) do
  post = Blog.get_post!(id)

  case Blog.publish_post(post) do
    {:ok, _post} ->
      {:noreply,
       socket
       |> put_flash(:info, "Post published successfully")
       |> assign(:posts, Blog.list_all_posts())}

    {:error, _changeset} ->
      {:noreply, put_flash(socket, :error, "Could not publish post")}
  end
end
```

### BlogPostLive.FormComponent

**Events handled**:
- `save` - Create or update blog post (handles scheduled_email_for)
- `validate` - Validate form on change

**Example save handler**:
```elixir
defp save_post(socket, :new, post_params) do
  case Blog.create_post(post_params) do
    {:ok, post} ->
      notify_parent({:saved, post})

      {:noreply,
       socket
       |> put_flash(:info, "Post created successfully")
       |> push_navigate(to: socket.assigns.navigate)}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, changeset: changeset)}
  end
end
```

---

### SubscriberLive.Index *(NEW)*

**Events handled**:
- `delete` - Delete a subscriber

**Example event handler**:
```elixir
@impl true
def handle_event("delete", %{"id" => id}, socket) do
  subscriber = Newsletter.get_subscriber!(id)
  {:ok, _} = Newsletter.delete_subscriber(subscriber)

  {:noreply,
   socket
   |> put_flash(:info, "Subscriber deleted successfully")
   |> assign(:subscribers, Newsletter.list_subscribers())}
end
```

### SubscriberLive.FormComponent *(NEW)*

**Events handled**:
- `save` - Create or update subscriber
- `validate` - Validate form on change

---

## URL Patterns

**Admin URLs**:
- `/admin/blog/posts` - Blog post index
- `/admin/blog/posts/123` - Blog post show
- `/admin/blog/posts/new` - New blog post form
- `/admin/blog/posts/123/edit` - Edit blog post form
- `/admin/subscribers` - Subscriber index
- `/admin/subscribers/123` - Subscriber show
- `/admin/subscribers/new` - New subscriber form
- `/admin/subscribers/123/edit` - Edit subscriber form

**Public URLs**:
- `/unsubscribe?token=eyJhbGc...` - Unsubscribe confirmation

---

## Form Schemas

### BlogPost Form

**Fields**:
```elixir
<.form for={@form} id="blog-post-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:title]} type="text" label="Title" required />
  <.input field={@form[:content]} type="textarea" label="Content" required />
  <.input field={@form[:excerpt]} type="textarea" label="Excerpt" />
  <.input field={@form[:status]} type="select" label="Status" options={["draft", "published"]} />
  <.input field={@form[:scheduled_email_for]} type="datetime-local" label="Schedule email for" />
  <.input field={@form[:tags]} type="text" label="Tags (comma-separated)" />

  <:actions>
    <.button type="submit">Save Post</.button>
    <.button type="button" phx-click="publish" phx-value-id={@post.id} :if={@post.status == "draft"}>
      Publish
    </.button>
    <.button type="button" phx-click="unpublish" phx-value-id={@post.id} :if={@post.status == "published"}>
      Unpublish
    </.button>
  </:actions>
</.form>
```

**Validation**:
- Title: required, min 3 chars
- Content: required, min 10 chars
- scheduled_email_for: must be future date if set
- Status: must be "draft" or "published"

---

### Subscriber Form *(NEW)*

**Fields**:
```elixir
<.form for={@form} id="subscriber-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:email]} type="email" label="Email" required />
  <.input field={@form[:verified]} type="checkbox" label="Verified" />

  <:actions>
    <.button type="submit">Save Subscriber</.button>
  </:actions>
</.form>
```

**Validation**:
- Email: required, valid format, unique

---

## Response Formats

All LiveView responses use standard Phoenix patterns:
- `{:noreply, socket}` - No additional navigation
- `{:noreply, push_navigate(socket, to: path)}` - Redirect after action
- `{:noreply, put_flash(socket, :info, message)}` - Flash message

Controller responses:
- `render(conn, :template, assigns)` - Render template
- `redirect(to: path)` - Redirect

---

## Authorization

**Admin routes**: Protected by `:require_authenticated_user` plug
**Public routes**: No authentication required (unsubscribe accessible to anyone with valid token)

**Authorization checks**:
- Admin actions: User must be authenticated admin
- Unsubscribe: Token must be valid (signed with Phoenix.Token)

---

## Testing Expectations

**LiveView Route Tests**:
- Test each route renders correctly
- Test authenticated access (admin routes)
- Test unauthenticated redirect
- Test form submission creates/updates records
- Test events (publish, unpublish, delete)
- Do NOT test HTML structure

**Controller Route Tests**:
- Test valid token unsubscribes user
- Test invalid token redirects with error
- Test unsubscribe page renders

**Examples**:
```elixir
test "admin can access blog post index", %{conn: conn} do
  conn = log_in_admin(conn)
  {:ok, _index_live, html} = live(conn, ~p"/admin/blog/posts")
  assert html =~ "Blog Posts"
end

test "valid token unsubscribes user", %{conn: conn} do
  subscriber = subscriber_fixture()
  token = Phoenix.Token.sign(conn, "unsubscribe", subscriber.id)

  conn = get(conn, ~p"/unsubscribe?token=#{token}")
  assert html_response(conn, 200) =~ "unsubscribed"

  updated = Repo.get!(Subscriber, subscriber.id)
  assert updated.subscription_status == "unsubscribed"
end
```
