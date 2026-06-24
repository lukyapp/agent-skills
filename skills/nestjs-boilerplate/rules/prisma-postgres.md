# prisma-postgres

## Use When

- Adding persistence, migrations, database models, or repositories.
- Editing `prisma/schema.prisma`.
- Creating services that need database access.

## Rule

Use Prisma 7 with the PostgreSQL adapter. Generate the Prisma client into
`src/generated/prisma`, inject a shared `PrismaService`, and connect through
Nest lifecycle hooks.

Never hand-write Prisma migration SQL or migration folders. Edit
`prisma/schema.prisma`, then create migrations with the Prisma CLI so Prisma
owns the migration name, folder, SQL, and lockfile changes.

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

```sql
-- prisma/migrations/20260101000000_add_projects/migration.sql
CREATE TABLE "Project" (
  "id" TEXT NOT NULL PRIMARY KEY
);
```

## Notes

- `PrismaModule` should provide and export only `PrismaService` unless the repo
  has a stronger pattern.
- `PrismaService` should call `$connect()`, run a lightweight `SELECT 1`, and
  disconnect in `onModuleDestroy`.
- Ignore `src/generated/**` in ESLint.
- Use `pnpm prisma:generate`, `pnpm prisma:migrate:dev`, and
  `pnpm prisma:migrate:deploy` scripts.
- When schema changes require a migration, run
  `pnpm prisma:migrate:dev --name <migration-name>` in development or the
  repository's equivalent migration command. Do not create or edit
  `prisma/migrations/**/migration.sql` manually unless the user explicitly asks
  for a hand-authored data migration or hotfix.
- Add indexes and unique constraints intentionally when adding models.
