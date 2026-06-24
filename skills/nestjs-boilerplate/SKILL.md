---
name: lukyapp-nestjs-boilerplate
description: Use when creating, modifying, or reviewing NestJS API backends that should follow Luky app boilerplate conventions. Applies to NestJS modules, bootstrap setup, Prisma/Postgres, OIDC JWT auth with JWKS, permissions, environment validation, Swagger, global error responses, throttling, validation pipes, and backend testing; prefer these rules over generic NestJS defaults when the target repository has no clearer local precedent.
---

# NestJS Boilerplate

Use this skill to follow Luky app NestJS conventions instead of inventing local
backend patterns. Prefer the target repository's existing code first, then these
rules when the repository has no clear precedent.

## Workflow

1. Inspect the target API before editing:
   - `package.json`
   - `src/main.ts`
   - `src/app.module.ts`
   - `prisma/schema.prisma`
   - existing modules, decorators, guards, services, and tests
2. Use installed dependencies and local helpers. Do not add a competing library
   when an approved or existing one already solves the job.
3. Read only the relevant files in `rules/` for the task:
   - choosing project libraries: `rules/library-selection.md`
   - bootstrap, Helmet, CORS, validation, Swagger, and listen setup:
     `rules/app-bootstrap.md`
   - module organization and domain-first API code: `rules/module-structure.md`
   - environment variables and startup validation: `rules/env-validation.md`
   - Prisma 7 with PostgreSQL adapter: `rules/prisma-postgres.md`
   - DTO validation and request trust boundaries: `rules/dto-validation.md`
   - OIDC JWT auth and JWKS signing keys: `rules/oidc-jwt-auth.md`
   - route decorators and controller helpers: `rules/decorators.md`
   - relation-style permissions: `rules/permissions.md`
   - global API error shape: `rules/error-contract.md`
   - Swagger/OpenAPI conventions: `rules/swagger-openapi.md`
   - security defaults and throttling: `rules/security-throttling.md`
   - dates and small helpers: `rules/helpers.md`
   - TypeScript, linting, formatting, and generated code: `rules/typescript-tooling.md`
   - unit and e2e tests: `rules/testing.md`
4. Keep generated code typed, direct, and production-oriented.
5. If the user names a preferred library or pattern that is not documented yet,
   follow it for the current task and suggest adding a new rule file.

## Maintenance

After adding or changing rules, regenerate the compiled guide:

```bash
node skills/nestjs-boilerplate/scripts/compile-agents.mjs
```

## Compiled Guide

For a complete single-file version of the current rules, read `AGENTS.md`.
