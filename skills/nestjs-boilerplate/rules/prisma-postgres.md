# prisma-postgres

## Use When

- Adding persistence, migrations, database models, or repositories.
- Editing `prisma/schema.prisma`.
- Creating services that need database access.

## Rule

Use Prisma 7 with the PostgreSQL adapter. Generate the Prisma client into
`src/generated/prisma`, inject a shared `PrismaService`, and connect through
Nest lifecycle hooks.

## Prefer

```prisma
generator client {
  provider     = "prisma-client"
  output       = "../src/generated/prisma"
  moduleFormat = "cjs"
}

datasource db {
  provider = "postgresql"
}
```

```ts
@Injectable()
export class ProjectsService {
  constructor(private readonly prisma: PrismaService) {}
}
```

## Avoid

```ts
const prisma = new PrismaClient();
```

## Notes

- `PrismaModule` should provide and export only `PrismaService` unless the repo
  has a stronger pattern.
- `PrismaService` should call `$connect()`, run a lightweight `SELECT 1`, and
  disconnect in `onModuleDestroy`.
- Ignore `src/generated/**` in ESLint.
- Use `pnpm prisma:generate`, `pnpm prisma:migrate:dev`, and
  `pnpm prisma:migrate:deploy` scripts.
- Add indexes and unique constraints intentionally when adding models.
