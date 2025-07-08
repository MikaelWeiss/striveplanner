# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix web application for Strive Planner, a marketing website for an iOS goal-setting app. The site provides information about the app, contact forms, and basic static pages.

## Architecture

- **Framework**: Phoenix 1.7.14 with Elixir
- **Frontend**: Server-side rendered HTML with Tailwind CSS and minimal JavaScript
- **Email**: Resend service for contact form submissions
- **Deployment**: Configured for Fly.io (see `fly.toml`)

### Key Components

- **StrivePlannerWeb.PageController**: Handles all static pages and contact form
- **StrivePlannerWeb.CoreComponents**: Reusable UI components using Phoenix Component
- **StrivePlanner.Email**: Email sending functionality via Resend
- **Assets**: Tailwind CSS and esbuild for frontend compilation

## Development Commands

### Setup and Dependencies
```bash
mix setup                    # Install dependencies and build assets
mix deps.get                 # Install Elixir dependencies
mix assets.setup             # Install frontend dependencies
mix assets.build             # Build frontend assets
```

### Development Server
```bash
mix phx.server               # Start development server
iex -S mix phx.server        # Start server with interactive shell
```

### Testing
```bash
mix test                     # Run all tests
mix test --stale             # Run only stale tests
mix test path/to/test.exs    # Run specific test file
```

### Asset Management
```bash
mix assets.deploy            # Build and minify assets for production
mix tailwind strive_planner  # Build Tailwind CSS
mix esbuild strive_planner   # Build JavaScript
```

### Code Quality
```bash
mix format                   # Format Elixir code
mix credo                    # Static code analysis (if available)
```

## Project Structure

- `lib/strive_planner_web/` - Web layer (controllers, components, templates)
- `lib/strive_planner/` - Core application logic
- `assets/` - Frontend assets (CSS, JS, Tailwind config)
- `priv/static/` - Static assets (images, videos, compiled assets)
- `config/` - Application configuration
- `test/` - Test files

## Key Files

- `lib/strive_planner_web/router.ex` - Route definitions
- `lib/strive_planner_web/controllers/page_controller.ex` - Main controller
- `lib/strive_planner_web/components/core_components.ex` - UI components
- `lib/strive_planner/email.ex` - Email functionality
- `mix.exs` - Project configuration and dependencies
- `assets/tailwind.config.js` - Tailwind CSS configuration

## Important Notes

- All media assets (images, videos) in `/priv/static/` are copyrighted by Weiss Solutions LLC
- The app uses Phoenix LiveView components but is primarily server-rendered
- Contact form submissions are sent via Resend to contact@striveplanner.org
- Development includes LiveDashboard at `/dev/dashboard` (dev environment only)
- Static paths include: assets, fonts, images, favicon.ico, robots.txt, sitemap.xml, videos

## Common Development Patterns

- Use `use StrivePlannerWeb, :controller` for controllers
- Use `use StrivePlannerWeb, :html` for HTML components
- Follow Phoenix conventions for naming and structure
- Templates are in `.html.heex` format (HEEx templates)
- Use `~p` sigil for verified routes
