# library-selection

## Use When

- Creating or modifying NestJS backend code.
- Choosing a package for auth, persistence, validation, Swagger, throttling,
  security middleware, logging, testing, or configuration.
- Refactoring code that introduced a one-off helper or duplicate abstraction.

## Rule

Use the repository's installed dependencies and established wrappers before
introducing new packages.

Prefer this boilerplate stack when starting from scratch:

- NestJS 11 with `@nestjs/platform-express`.
- Prisma 7 with `@prisma/adapter-pg` and PostgreSQL.
- `@nestjs/config` with class-validator/class-transformer env validation.
- `passport-jwt`, `jsonwebtoken`, and `jwks-rsa` for OIDC bearer auth.
- `@nestjs/swagger` for OpenAPI.
- `helmet`, CORS, and `@nestjs/throttler` for baseline HTTP hardening.
- Jest and Supertest for unit and e2e tests.

## Prefer

```ts
import { PrismaService } from "../prisma/prisma.service";

export class UsersService {
  constructor(private readonly prisma: PrismaService) {}
}
```

## Avoid

```ts
import { Pool } from "pg";

export const pool = new Pool({ connectionString: process.env.DATABASE_URL });
```

## Notes

- Existing repository architecture beats this skill when the repo is more
  specific.
- Add a new rule file when a dependency choice becomes a recurring convention.
