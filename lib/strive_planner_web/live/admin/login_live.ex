defmodule StrivePlannerWeb.Admin.LoginLive do
  use StrivePlannerWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"email" => ""}, as: :login), email_sent: false, loading: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center py-16 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-normal text-white mb-3">
            Admin Sign In
          </h2>
          <p class="text-sm text-gray-300">
            Enter your admin email to receive a magic link
          </p>
        </div>

        <%!-- Flash Messages --%>
        <div class="mb-4">
          <.flash :if={@flash["error"]} kind={:error} flash={@flash} />
          <.flash :if={@flash["info"]} kind={:info} flash={@flash} />
        </div>

        <%= if @email_sent do %>
          <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8 border border-[#40e0d0]/20">
            <div class="flex items-start">
              <div class="flex-shrink-0">
                <.icon name="hero-check-circle" class="h-6 w-6 text-[#40e0d0]" />
              </div>
              <div class="ml-4">
                <h3 class="text-base font-medium text-white mb-2">
                  Magic link sent!
                </h3>
                <p class="text-sm text-gray-300 leading-relaxed">
                  Check your email for a sign-in link. The link will expire in 15 minutes.
                </p>
              </div>
            </div>
          </div>
        <% else %>
          <div class="bg-white/5 backdrop-blur-lg rounded-lg p-8">
            <.form for={@form} id="login-form" phx-submit="send_magic_link" class="space-y-6">
              <div>
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email Address"
                  placeholder="admin@example.com"
                  required
                  class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-md text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-[#40e0d0] focus:border-transparent transition-all"
                />
              </div>

              <div>
                <button
                  type="submit"
                  disabled={@loading}
                  class={[
                    "w-full flex justify-center py-3 px-4 text-sm font-medium rounded-md text-gray-900 bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#40e0d0] transition-all",
                    @loading && "opacity-50 cursor-not-allowed"
                  ]}
                >
                  <%= if @loading do %>
                    <.icon name="hero-arrow-path" class="h-5 w-5 animate-spin mr-2" />
                    Sending...
                  <% else %>
                    Send Magic Link
                  <% end %>
                </button>
              </div>
            </.form>
          </div>
        <% end %>

        <div class="text-center mt-8">
          <a href="/" class="text-sm text-gray-300 hover:text-white transition-colors">
            ← Back to home
          </a>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("send_magic_link", %{"login" => %{"email" => email}}, socket) do
    require Logger
    Logger.info("Login attempt for email: #{email}")

    socket = assign(socket, loading: true)

    # Rate limit: 3 attempts per email per 15 minutes
    rate_limit_key = "admin_login:#{email}"

    socket =
      case StrivePlanner.RateLimiter.check_rate(rate_limit_key, 3, 15 * 60 * 1000) do
        :ok ->
          Logger.info("Rate limit check passed")

          case StrivePlanner.Accounts.generate_admin_magic_link(email) do
            {:ok, user, token} ->
              Logger.info("Magic link generated successfully for user: #{user.id}")
              StrivePlanner.Email.send_admin_magic_link(user, token)
              assign(socket, email_sent: true, loading: false)

            {:error, :user_not_found} ->
              Logger.warning("Login attempt for non-existent user: #{email}")
              socket
              |> assign(loading: false)
              |> put_flash(:error, "No admin account found with that email address.")

            {:error, :not_admin} ->
              Logger.warning("Login attempt for non-admin user: #{email}")
              socket
              |> assign(loading: false)
              |> put_flash(:error, "This email is not associated with an admin account.")

            {:error, reason} ->
              Logger.error("Error generating magic link: #{inspect(reason)}")
              socket
              |> assign(loading: false)
              |> put_flash(:error, "An error occurred. Please try again.")
          end

        {:error, :rate_limited} ->
          Logger.warning("Rate limit exceeded for: #{email}")
          socket
          |> assign(loading: false)
          |> put_flash(
            :error,
            "Too many login attempts. Please try again in 15 minutes."
          )
      end

    {:noreply, socket}
  end
end
