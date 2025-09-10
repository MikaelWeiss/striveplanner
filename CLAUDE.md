# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Strive Planner marketing website - a SvelteKit application for showcasing the Strive Planner iOS app. The site includes landing pages, blog functionality, and serves as the web presence for the mobile app.

## Development Environment

**Package Manager:** pnpm (configured in package.json)
**Framework:** SvelteKit with TypeScript
**Styling:** Tailwind CSS
**Deployment:** Fly.io (configured via fly.toml)

### Essential Commands

```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Type checking
pnpm check

# Type checking with watch mode
pnpm check:watch

# Format code
pnpm format

# Lint code
pnpm lint
```

### Java Setup for Android Development

When working with the Android app (in `strive-android/` directory), ensure Java 17 is properly configured:

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
cd strive-android && ./gradlew assembleDebug
```

## Project Architecture

### Core Structure

- **SvelteKit Routes:** File-based routing in `src/routes/`
- **Layout System:** `src/routes/+layout.svelte` provides navigation and footer
- **Blog System:** Markdown-based blog with static generation in `src/lib/blog/`
- **Static Assets:** Images, videos, and assets in `static/`

### Key Components

- **Navigation:** Responsive header with mobile menu in layout
- **Styling:** Dark theme with gradient backgrounds using Tailwind CSS
- **Blog:** Markdown processing via mdsvex with TypeScript types
- **Assets:** Organized in `static/images/` with favicon structure

### Build Configuration

- **Adapter:** Node.js adapter for server-side rendering
- **Markdown:** mdsvex for `.md` file processing
- **Extensions:** `.svelte`, `.svx`, `.md` files supported
- **Preprocessing:** Vite with Svelte preprocessing

### Important Files

- `svelte.config.js`: SvelteKit configuration with mdsvex and Node adapter
- `vite.config.ts`: Vite build configuration
- `tailwind.config.js`: Tailwind CSS configuration (via @tailwindcss/vite)
- `eslint.config.js`: ESLint configuration with Svelte support
- `fly.toml`: Fly.io deployment configuration

### Mobile App Integration

The site promotes the iOS app available on the App Store. The Android app is developed separately in the `strive-android/` directory and should be brought to feature parity with the iOS version.

### Deployment

Built for Fly.io deployment with Docker configuration. The app uses server-side rendering with the Node.js adapter for optimal performance.