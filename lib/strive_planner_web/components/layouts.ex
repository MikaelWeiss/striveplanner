defmodule StrivePlannerWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use StrivePlannerWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <!-- Navigation -->
    <nav class="bg-[#1a2b33] bg-opacity-90 shadow-lg px-4 sm:px-6 lg:px-8">
      <div class="max-w-7xl mx-auto">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <a href="/" class="flex items-center">
              <img src={~p"/images/logo.png"} alt="Logo" class="h-8 w-8" />
              <span class="ml-2 text-white font-medium">Strive</span>
            </a>
          </div>
          <div class="hidden md:block">
            <div class="flex items-center space-x-4">
              <a href="/" class="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm">
                Home
              </a>
              <a href="/blog" class="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm">
                Blog
              </a>
              <a href="/contact" class="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm">
                Contact
              </a>
              <a href="/support" class="text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm">
                Support
              </a>
              <a
                href="https://apps.apple.com/app/apple-store/id6472100413?pt=127673313&ct=StrivePlannerWebsite&mt=8"
                class="bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 px-4 py-2 rounded-md text-sm font-medium hover:opacity-90"
              >
                Download
              </a>
            </div>
          </div>
          <div class="md:hidden">
            <button
              type="button"
              id="mobile-menu-button"
              phx-click={toggle_mobile_menu()}
              class="text-gray-300 hover:text-white"
            >
              <span class="sr-only">Open main menu</span>
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
      <!-- Mobile menu -->
      <div id="mobile-menu" class="hidden md:hidden">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <a href="/" class="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base">
            Home
          </a>
          <a
            href="/blog"
            class="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base"
          >
            Blog
          </a>
          <a
            href="/contact"
            class="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base"
          >
            Contact
          </a>
          <a
            href="/support"
            class="text-gray-300 hover:text-white block px-3 py-2 rounded-md text-base"
          >
            Support
          </a>
          <a
            href="https://apps.apple.com/app/apple-store/id6472100413?pt=127673313&ct=StrivePlannerWebsite&mt=8"
            class="bg-gradient-to-r from-[#40e0d0] to-[#3bd89d] text-gray-900 block px-3 py-2 rounded-md text-base font-medium hover:opacity-90"
          >
            Download
          </a>
        </div>
      </div>
    </nav>
    <!-- Main Content -->
    <main>
      {render_slot(@inner_block)}
    </main>
    <!-- Footer -->
    <footer class="bg-[#1a2b33] text-gray-300">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div class="space-y-4">
            <img src={~p"/images/logo.png"} alt="Logo" class="h-8 w-8" />
            <p class="text-sm">Shape your life, one day at a time.</p>
          </div>
          <div>
            <h3 class="text-white font-medium mb-4">Company</h3>
            <ul class="space-y-2 text-sm">
              <li>
                <a href="/about" class="hover:text-white">About</a>
              </li>
            </ul>
          </div>
          <div>
            <h3 class="text-white font-medium mb-4">Legal</h3>
            <ul class="space-y-2 text-sm">
              <li>
                <a href="/privacy" class="hover:text-white">Privacy</a>
              </li>
              <li>
                <a href="/terms-of-service" class="hover:text-white">Terms of Service</a>
              </li>
            </ul>
          </div>
        </div>
        <div class="border-t border-gray-800 mt-12 pt-8 text-sm text-center">
          <p>&copy; 2024 Weiss Solutions LLC. All rights reserved.</p>
        </div>
      </div>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  defp toggle_mobile_menu(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#mobile-menu")
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
