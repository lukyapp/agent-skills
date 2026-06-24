# module-structure

## Use When

- Adding a new business capability.
- Moving controllers, services, guards, decorators, or persistence code.
- Deciding where shared backend utilities belong.

## Rule

Organize code by Nest modules and business domains. Keep shared infrastructure
in focused top-level modules such as `auth`, `common`, `env`, `errors`, and
`prisma`; keep product-specific code in its own domain module.

## Prefer

```text
src/
  auth/
  common/
  errors/
  prisma/
  projects/
    projects.controller.ts
    projects.module.ts
    projects.service.ts
```

## Avoid

```text
src/
  controllers/
  services/
  repositories/
```

## Notes

- Export module public APIs through `index.ts` when it improves imports.
- Keep `AppModule` for wiring global modules, guards, filters, and domain
  modules.
- Do not encode application-specific sample modules as boilerplate rules.
