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
   - API calls, server state, loading, errors, mutations: `rules/react-query-api-calls.md`
   - choosing and extending project libraries: `rules/library-selection.md`
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
