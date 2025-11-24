defmodule StrivePlannerWeb.Admin.DashboardLive do
  use StrivePlannerWeb, :live_view

  alias StrivePlanner.Blog
  alias StrivePlanner.Blog.BlogPost

  def mount(_params, _session, socket) do
    posts = Blog.list_all_posts()

    {:ok,
     socket
     |> assign(:posts, posts)
     |> assign(:selected_post, nil)
     |> assign(:mode, :new)
     |> assign(:form, to_form(Blog.change_post(%BlogPost{})))
     |> stream(:posts, posts)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen bg-[#0f1a1f]">
      <!-- Navigation Bar -->
      <div class="bg-[#1a2b33] border-b border-white/10">
        <div class="max-w-7xl mx-auto px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <.link
                navigate={~p"/admin"}
                class="px-6 py-2 rounded-full text-gray-900 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] font-medium"
              >
                Blog Posts
              </.link>
              <.link
                navigate={~p"/admin/subscribers"}
                class="px-6 py-2 rounded-full text-white bg-white/10 hover:bg-white/20 font-medium transition-all"
              >
                Subscribers
              </.link>
            </div>
            <a
              href="/admin/logout"
              class="text-sm text-gray-300 hover:text-white transition-colors"
            >
              Logout
            </a>
          </div>
        </div>
      </div>
      <!-- Main Content -->
      <div class="flex flex-1 overflow-hidden">
        <!-- Sidebar -->
        <div class="w-80 bg-[#1a2b33] border-r border-white/10 overflow-y-auto">
          <div class="p-6 border-b border-white/10">
            <h1 class="text-xl font-normal text-white mb-6">Blog Posts</h1>
            <button
              phx-click="new_post"
              class="w-full px-4 py-2.5 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 rounded-md hover:opacity-90 font-medium transition-all"
            >
              New Blog Post
            </button>
          </div>

          <div id="posts" phx-update="stream" class="p-3 space-y-2">
            <div
              :for={{id, post} <- @streams.posts}
              id={id}
              phx-click="select_post"
              phx-value-id={post.id}
              class={[
                "p-4 cursor-pointer rounded-lg transition-all",
                @selected_post && @selected_post.id == post.id && "bg-white/10",
                (!@selected_post || @selected_post.id != post.id) && "hover:bg-white/5"
              ]}
            >
              <h3 class="font-medium text-white mb-2 truncate">{post.title}</h3>
              <div class="flex items-center gap-2 text-xs mb-2">
                <span class={[
                  "px-2 py-0.5 rounded-full font-medium",
                  post.status == "published" && "bg-[#40e0d0]/20 text-[#40e0d0]",
                  post.status == "draft" && "bg-white/10 text-gray-300",
                  post.status == "scheduled" && "bg-blue-400/20 text-blue-400"
                ]}>
                  {post.status}
                </span>
                <span class="text-gray-400">
                  {if post.published_at,
                    do: Calendar.strftime(post.published_at, "%b %d, %Y"),
                    else: "Not published"}
                </span>
              </div>
              <div class="flex items-center gap-4 text-xs text-gray-400">
                <span title="Views">
                  <.icon name="hero-eye" class="w-3 h-3 inline" /> Views: {post.view_count}
                </span>
                <%= if post.email_sent_at do %>
                  <span title="Email sent" class="text-[#40e0d0]">
                    <.icon name="hero-envelope" class="w-3 h-3 inline" />
                    Recipients: {post.email_recipient_count}
                  </span>
                <% else %>
                  <span title="Not sent">
                    <.icon name="hero-envelope" class="w-3 h-3 inline" /> Not sent
                  </span>
                <% end %>
              </div>
            </div>
          </div>
        </div>
        <!-- Main Content Area -->
        <div class="flex-1 overflow-y-auto bg-[#0f1a1f]">
          <div class="max-w-4xl mx-auto p-8">
            <%= if @mode == :new do %>
              <div class="mb-8">
                <h2 class="text-2xl font-normal text-white">Create New Blog Post</h2>
              </div>
              <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
                <.form
                  for={@form}
                  id="blog-form"
                  phx-submit="save_post"
                  phx-change="validate"
                  class="space-y-6"
                >
                  <.blog_form_fields form={@form} />
                  <div class="flex gap-3 pt-4">
                    <button
                      type="submit"
                      class="px-6 py-2.5 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 rounded-md hover:opacity-90 font-medium transition-all"
                    >
                      Create Post
                    </button>
                  </div>
                </.form>
              </div>
            <% end %>

            <%= if @mode == :view && @selected_post do %>
              <div class="mb-8 flex items-center justify-between">
                <h2 class="text-2xl font-normal text-white">View Blog Post</h2>
                <div class="flex gap-2">
                  <%= if not @selected_post.sent_to_subscribers do %>
                    <button
                      phx-click="send_to_subscribers"
                      data-confirm="Send this post to all newsletter subscribers?"
                      class="px-4 py-2.5 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 rounded-md hover:opacity-90 font-medium transition-all"
                    >
                      Send to Subscribers
                    </button>
                  <% end %>
                  <button
                    phx-click="edit_post"
                    class="px-4 py-2.5 bg-white/10 text-white rounded-md hover:bg-white/20 font-medium transition-all"
                  >
                    Edit
                  </button>
                  <button
                    phx-click="delete_post"
                    data-confirm="Are you sure you want to delete this post?"
                    class="px-4 py-2.5 bg-red-500/20 text-red-400 rounded-md hover:bg-red-500/30 font-medium transition-all"
                  >
                    Delete
                  </button>
                </div>
              </div>
              <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
                <h1 class="text-3xl font-normal text-white mb-6">{@selected_post.title}</h1>
                <div class="flex gap-4 text-sm text-gray-400 mb-8 pb-6 border-b border-white/10">
                  <span>Status: <span class="text-white">{@selected_post.status}</span></span>
                  <span>Slug: <span class="text-white">{@selected_post.slug}</span></span>
                  <%= if @selected_post.published_at do %>
                    <span>
                      Published:
                      <span class="text-white">
                        {Calendar.strftime(@selected_post.published_at, "%B %d, %Y")}
                      </span>
                    </span>
                  <% end %>
                </div>
                <%= if @selected_post.excerpt do %>
                  <div class="mb-8">
                    <h3 class="font-medium text-white mb-3">Excerpt</h3>
                    <p class="text-gray-300 leading-relaxed">{@selected_post.excerpt}</p>
                  </div>
                <% end %>
                <div class="mb-8">
                  <h3 class="font-medium text-white mb-3">Content</h3>
                  <div class="prose prose-invert max-w-none">
                    {Phoenix.HTML.raw(Blog.render_markdown(@selected_post.content))}
                  </div>
                </div>
                <%= if not Enum.empty?(@selected_post.tags) do %>
                  <div class="mb-6">
                    <h3 class="font-medium text-white mb-3">Tags</h3>
                    <div class="flex flex-wrap gap-2">
                      <%= for tag <- @selected_post.tags do %>
                        <span class="px-3 py-1 bg-[#40e0d0]/20 text-[#40e0d0] rounded-full text-sm">
                          {tag}
                        </span>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>

            <%= if @mode == :edit && @selected_post do %>
              <div class="mb-8">
                <h2 class="text-2xl font-normal text-white">Edit Blog Post</h2>
              </div>
              <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
                <.form
                  for={@form}
                  id="blog-form"
                  phx-submit="update_post"
                  phx-change="validate"
                  class="space-y-6"
                >
                  <.blog_form_fields form={@form} />
                  <div class="flex gap-3 pt-4">
                    <button
                      type="submit"
                      class="px-6 py-2.5 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 rounded-md hover:opacity-90 font-medium transition-all"
                    >
                      Update Post
                    </button>
                    <button
                      phx-click="cancel_edit"
                      type="button"
                      class="px-6 py-2.5 bg-white/10 text-white rounded-md hover:bg-white/20 font-medium transition-all"
                    >
                      Cancel
                    </button>
                  </div>
                </.form>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp blog_form_fields(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Title <span class="text-red-400">*</span>
        </label>
        <.input
          field={@form[:title]}
          type="text"
          required
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Slug
        </label>
        <.input
          field={@form[:slug]}
          type="text"
          placeholder="leave blank to auto-generate"
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Excerpt
        </label>
        <.input
          field={@form[:excerpt]}
          type="textarea"
          rows="3"
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Content (Markdown) <span class="text-red-400">*</span>
        </label>
        <.input
          field={@form[:content]}
          type="textarea"
          rows="15"
          required
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all font-mono text-sm"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Tags (comma-separated)
        </label>
        <.input
          field={@form[:tags]}
          type="text"
          placeholder="productivity, goals, planning"
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Meta Description (SEO)
        </label>
        <.input
          field={@form[:meta_description]}
          type="textarea"
          rows="2"
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-300 mb-2">
          Featured Image URL
        </label>
        <.input
          field={@form[:featured_image]}
          type="text"
          class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
        />
      </div>

      <div class="grid grid-cols-2 gap-6">
        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Status
          </label>
          <.input
            field={@form[:status]}
            type="select"
            options={["draft", "scheduled", "published"]}
            class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-300 mb-2">
            Publish Date/Time
          </label>
          <.input
            field={@form[:published_at]}
            type="datetime-local"
            class="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
          />
        </div>
      </div>
    </div>
    """
  end

  def handle_event("new_post", _params, socket) do
    {:noreply,
     socket
     |> assign(:mode, :new)
     |> assign(:selected_post, nil)
     |> assign(:form, to_form(Blog.change_post(%BlogPost{})))}
  end

  def handle_event("select_post", %{"id" => id}, socket) do
    post = Blog.get_post!(id)

    {:noreply,
     socket
     |> assign(:mode, :view)
     |> assign(:selected_post, post)}
  end

  def handle_event("edit_post", _params, socket) do
    {:noreply,
     socket
     |> assign(:mode, :edit)
     |> assign(:form, to_form(Blog.change_post(socket.assigns.selected_post)))}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:mode, :view)}
  end

  def handle_event("delete_post", _params, socket) do
    case Blog.delete_post(socket.assigns.selected_post) do
      {:ok, _post} ->
        posts = Blog.list_all_posts()

        {:noreply,
         socket
         |> put_flash(:info, "Blog post deleted successfully.")
         |> assign(:posts, posts)
         |> assign(:mode, :new)
         |> assign(:selected_post, nil)
         |> assign(:form, to_form(Blog.change_post(%BlogPost{})))
         |> stream(:posts, posts, reset: true)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete post.")}
    end
  end

  def handle_event("send_to_subscribers", _params, socket) do
    case Blog.send_to_subscribers(socket.assigns.selected_post) do
      {:ok, count} ->
        # Refresh the post to get updated stats
        post = Blog.get_post!(socket.assigns.selected_post.id)
        posts = Blog.list_all_posts()

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Queued #{count} emails for delivery. Emails are being sent in the background to comply with rate limits."
         )
         |> assign(:selected_post, post)
         |> assign(:posts, posts)
         |> stream(:posts, posts, reset: true)}

      {:error, :no_subscribers} ->
        {:noreply,
         socket
         |> put_flash(:error, "No verified subscribers found.")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to queue emails. Please try again.")}
    end
  end

  def handle_event("validate", %{"blog_post" => params}, socket) do
    changeset =
      case socket.assigns.mode do
        :new -> Blog.change_post(%BlogPost{}, parse_params(params))
        :edit -> Blog.change_post(socket.assigns.selected_post, parse_params(params))
        _ -> Blog.change_post(%BlogPost{}, parse_params(params))
      end

    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save_post", %{"blog_post" => params}, socket) do
    case Blog.create_post(parse_params(params)) do
      {:ok, post} ->
        posts = Blog.list_all_posts()

        {:noreply,
         socket
         |> put_flash(:info, "Blog post created successfully.")
         |> assign(:posts, posts)
         |> assign(:mode, :view)
         |> assign(:selected_post, post)
         |> stream(:posts, posts, reset: true)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("update_post", %{"blog_post" => params}, socket) do
    case Blog.update_post(socket.assigns.selected_post, parse_params(params)) do
      {:ok, post} ->
        posts = Blog.list_all_posts()

        {:noreply,
         socket
         |> put_flash(:info, "Blog post updated successfully.")
         |> assign(:posts, posts)
         |> assign(:mode, :view)
         |> assign(:selected_post, post)
         |> stream(:posts, posts, reset: true)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, action: :update))}
    end
  end

  defp parse_params(params) do
    params
    |> Map.update("tags", [], fn tags ->
      if is_binary(tags) do
        tags
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
      else
        tags
      end
    end)
    |> Map.update("published_at", nil, fn published_at ->
      if published_at && published_at != "" do
        # datetime-local sends format without seconds, add ":00" if needed
        datetime_str =
          if String.match?(published_at, ~r/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/),
            do: published_at <> ":00",
            else: published_at

        case NaiveDateTime.from_iso8601(datetime_str) do
          {:ok, naive} -> DateTime.from_naive!(naive, "Etc/UTC")
          _ -> nil
        end
      else
        nil
      end
    end)
  end
end
