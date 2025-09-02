# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Strive Planner is a Phoenix web application that serves as a marketing website for an iOS goal-setting app. The site provides static pages, contact forms, and basic information about the mobile application.

## Development Commands

### Project Setup
```bash
mix setup                    # Install dependencies and build assets (recommended for initial setup)
mix deps.get                 # Install Elixir dependencies
mix assets.setup             # Install frontend dependencies (Tailwind, esbuild)
mix assets.build             # Build frontend assets
```

### Development Server
```bash
mix phx.server               # Start development server (http://localhost:4000)
iex -S mix phx.server        # Start server with interactive Elixir shell
```

### Testing
```bash
mix test                     # Run all tests
mix test --stale             # Run only stale tests (changed files)
mix test path/to/test.exs    # Run specific test file
mix test --cover             # Run tests with coverage report
```

### Asset Management
```bash
mix assets.deploy            # Build and minify assets for production
mix tailwind strive_planner  # Build Tailwind CSS manually
mix esbuild strive_planner   # Build JavaScript manually
```

### Code Quality
```bash
mix format                   # Format Elixir code according to project style
mix format --check-formatted # Check if code is properly formatted (CI usage)
```

### Development Dashboard
- Visit `/dev/dashboard` in development for LiveDashboard (metrics, processes, etc.)

## Architecture Overview

### Technology Stack
- **Backend**: Phoenix 1.7.14 with Elixir ~> 1.14
- **Frontend**: Server-side rendered HTML with Tailwind CSS and minimal JavaScript
- **Email Service**: Resend API for contact form submissions
- **Security**: reCAPTCHA v3 for form protection
- **Deployment**: Configured for Fly.io hosting

### Application Structure

#### Core Application (`lib/strive_planner/`)
- `application.ex` - OTP application supervisor setup
- `email.ex` - Email sending functionality via Resend API

#### Web Layer (`lib/strive_planner_web/`)
- `router.ex` - Route definitions for all pages and API endpoints
- `endpoint.ex` - Phoenix endpoint configuration
- `controllers/page_controller.ex` - Main controller handling all static pages and contact form
- `controllers/changelog_controller.ex` - API controller for changelog data
- `components/core_components.ex` - Reusable Phoenix components
- `components/layouts.ex` - Layout components and templates

### Key Routes and Pages
- `/` - Home page
- `/about`, `/privacy`, `/terms`, `/terms-of-service` - Static informational pages
- `/contact` - Contact form (GET and POST)
- `/support` - Support page
- `/api/changelog` - JSON API endpoint for changelog data

### Asset Pipeline
- **Tailwind CSS**: Configured with custom brand color (#FD4F00) and Phoenix-specific variants
- **esbuild**: JavaScript bundling with ES2017 target
- **Heroicons**: Integrated icon system via Tailwind plugin
- Assets compiled to `priv/static/assets/`

### Email System Architecture
Contact form submissions flow through:
1. Form validation and reCAPTCHA verification in `PageController`
2. Email composition in `StrivePlanner.Email`
3. Delivery via Resend API to `contact@striveplanner.org`

### Configuration Management
- **Development**: `config/dev.exs` - Local development settings
- **Production**: `config/prod.exs` and `config/runtime.exs` - Production configuration
- **Environment Variables**: Resend API key, reCAPTCHA keys configured via runtime

### Static Assets and Media
- All media files in `priv/static/` are copyrighted by Weiss Solutions LLC
- Static file serving includes: assets, fonts, images, favicon.ico, robots.txt, sitemap.xml, videos

## Development Patterns

### Phoenix Conventions
- Controllers use `use StrivePlannerWeb, :controller`
- HTML components use `use StrivePlannerWeb, :html`
- Templates are HEEx format (`.html.heex`)
- Use `~p` sigil for verified routes (compile-time route verification)

### Component Architecture
- Reusable components defined in `core_components.ex`
- Layout components separated in `layouts.ex`
- Server-side rendering with minimal client-side JavaScript

### Form Handling
- Contact form includes reCAPTCHA v3 integration
- Form data validated before email sending
- Flash messages for user feedback
- Redirect after POST pattern implemented

## Important Files
- `mix.exs` - Project dependencies and build configuration
- `lib/strive_planner_web/router.ex` - All route definitions
- `assets/tailwind.config.js` - Tailwind CSS configuration
- `config/runtime.exs` - Runtime environment configuration
- `fly.toml` - Fly.io deployment configuration
