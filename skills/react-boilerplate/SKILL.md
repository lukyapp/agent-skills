---
name: lukyapp-react-boilerplate
description: Use when creating, modifying, or reviewing React, Next.js, or TypeScript frontend code in projects that should follow Luky app boilerplate conventions, preferred libraries, and architecture. Applies to API calls, data fetching, mutations, client state, forms, routing, component structure, styling choices, and frontend implementation patterns; prefer the rules in this skill over generic React defaults.
---

# React Boilerplate

Use this skill to follow Luky app React conventions instead of inventing local
patterns. Prefer the target repository's existing code first, then these rules
when the repository has no clear precedent.

## Workflow

1. Inspect the target app before editing:
   - `package.json`
   - framework config such as `next.config.*`, `vite.config.*`, or router files
   - existing API, query, form, component, and styling patterns
2. Use installed dependencies and local helpers. Do not add a new library when
   an approved or existing one already solves the job.
3. Read only the relevant files in `rules/` for the task:
   - creating a new React/Vite project: `rules/project-initialization.md`
   - choosing and extending project libraries: `rules/library-selection.md`
   - domain-first feature structure and React hexagonal architecture: `rules/domain-feature-structure.md`
   - shared API client, auth headers, JSON parsing: `rules/api-client.md`
   - API error response shape and UI mapping: `rules/api-error-contract.md`
   - API calls, server state, loading, errors, mutations: `rules/react-query-api-calls.md`
   - query keys and cache invalidation strategy: `rules/cache-invalidation.md`
   - form state and validation: `rules/forms-zod-react-hook-form.md`
   - runtime validation and trust boundaries: `rules/validation-zod.md`
   - environment variables: `rules/env-vars-zod.md`
   - client-only global UI state: `rules/client-state-zustand.md`
   - URL search params, filters, tabs, pagination: `rules/url-state-nuqs.md`
   - typed routing in React/Vite apps: `rules/routing-tanstack-router.md`
   - Next.js i18n with messages and translations: `rules/i18n-next-intl.md`
   - date parsing, formatting, and arithmetic: `rules/dates-date-fns.md`
   - mutation feedback and transient notifications: `rules/notifications-sonner.md`
   - UI components, styling, icons, dates, and toasts: `rules/ui-conventions.md`
   - mobile-first responsive layout and touch ergonomics: `rules/responsive-mobile.md`
   - loading, empty, error, and success states: `rules/async-ui-states.md`
   - tables, lists, filters, sorting, and pagination: `rules/tables-and-lists.md`
   - optimistic React Query mutations and rollback: `rules/optimistic-updates.md`
   - file uploads, previews, progress, and validation: `rules/file-uploads.md`
   - dialogs, drawers, and destructive confirmations: `rules/modals-and-confirmations.md`
   - accessible forms, controls, focus, and keyboard behavior: `rules/accessibility.md`
   - platformless typed analytics events and adapters: `rules/analytics-events.md`
   - unit, component, mock API, and e2e tests: `rules/testing.md`
   - light/dark theme tokens and semantic color utilities:
     `rules/theme-colors.md`
4. Keep generated code boring, typed, and easy to maintain.
5. If the user names a preferred library or pattern that is not documented yet,
   follow it for the current task and suggest adding a new rule file.

## Maintenance

After adding or changing rules, regenerate the compiled guide:

```bash
node skills/react-boilerplate/scripts/compile-agents.mjs
```

## Compiled Guide

For a complete single-file version of the current rules, read `AGENTS.md`.
