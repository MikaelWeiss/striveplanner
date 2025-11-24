defmodule StrivePlannerWeb.Router do
  use StrivePlannerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StrivePlannerWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; " <>
          "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.google.com https://www.gstatic.com https://static.cloudflareinsights.com; " <>
          "style-src 'self' 'unsafe-inline'; " <>
          "connect-src 'self' ws: wss: https://www.google.com https://cloudflareinsights.com https://static.cloudflareinsights.com; " <>
          "img-src 'self' data:; " <>
          "font-src 'self'; " <>
          "frame-src 'self' https://www.google.com https://www.gstatic.com; " <>
          "frame-ancestors 'none'; " <>
          "base-uri 'self'; " <>
          "form-action 'self'",
      "x-frame-options" => "DENY",
      "x-content-type-options" => "nosniff",
      "referrer-policy" => "strict-origin-when-cross-origin",
      "permissions-policy" => "geolocation=(), microphone=(), camera=()"
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_admin do
    plug StrivePlannerWeb.Plugs.RequireAdmin
  end

  scope "/", StrivePlannerWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    get "/support", PageController, :support
    get "/privacy", PageController, :privacy
    get "/terms-of-service", PageController, :terms_of_service
    get "/contact", PageController, :contact
    post "/contact", PageController, :contact_submit
    get "/newsletter/verify/:token", PageController, :verify_newsletter
    get "/newsletter/welcome", PageController, :newsletter_welcome
    get "/unsubscribe", Newsletter.UnsubscribeController, :unsubscribe
    get "/blog", PageController, :blog_index
    get "/blog/:slug", PageController, :blog_post
  end

  # API routes
  scope "/api", StrivePlannerWeb.API do
    pipe_through :api

    post "/newsletter/subscribe", NewsletterController, :subscribe
  end

  # Admin authentication routes (no auth required)
  scope "/admin", StrivePlannerWeb do
    pipe_through :browser

    live "/login", Admin.LoginLive, :index
    get "/verify/:token", AdminController, :verify
    get "/logout", AdminController, :logout
  end

  # Admin portal routes (auth required)
  scope "/admin", StrivePlannerWeb.Admin do
    pipe_through [:browser, :require_admin]

    live "/", DashboardLive, :index

    live "/subscribers", SubscriberLive.Index, :index
    live "/subscribers/new", SubscriberLive.Index, :new
    live "/subscribers/:id/edit", SubscriberLive.Index, :edit
    live "/subscribers/:id", SubscriberLive.Show, :show
    live "/subscribers/:id/show/edit", SubscriberLive.Show, :edit
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:strive_planner, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StrivePlannerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
