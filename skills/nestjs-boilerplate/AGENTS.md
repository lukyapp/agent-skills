# Luky App NestJS Boilerplate

This file is generated from `rules/*.md`.

Use these rules when creating, modifying, or reviewing NestJS API backend code
in projects that should follow Luky app boilerplate conventions.

Prefer the target repository's existing code first, then these rules when the
repository has no clear precedent.

## Workflow

1. Inspect `package.json`, `src/main.ts`, `src/app.module.ts`,
   `prisma/schema.prisma`, and nearby implementation patterns before editing.
2. Use installed dependencies and local helpers.
3. Keep code typed, direct, secure-by-default, and maintainable.
4. Add a new rule when a preference becomes recurring.

# Rule Sections

| Prefix | Section | Purpose |
| --- | --- | --- |
| `app-` | App Bootstrap | Configure platform-wide security, validation, CORS, Swagger, and listen behavior. |
| `decorators-` | Decorators | Keep auth, permissions, and Swagger route metadata reusable. |
| `dto-` | DTO Validation | Validate inbound request data through Nest DTOs and global pipes. |
| `env-` | Environment Validation | Fail startup when required configuration is missing or malformed. |
| `error-` | Error Contract | Return predictable HTTP error responses. |
| `helpers-` | Helpers | Centralize small reusable date and user helpers without over-abstracting. |
| `library-` | Library Selection | Choose approved backend dependencies and local abstractions. |
| `module-` | Module Structure | Organize API code by Nest modules and business domains. |
| `oidc-` | OIDC JWT Auth | Validate bearer tokens through OIDC discovery and JWKS. |
| `permissions-` | Permissions | Authorize routes with relation-style permission requirements. |
| `prisma-` | Prisma Postgres | Use Prisma 7 with the PostgreSQL adapter and lifecycle hooks. |
| `project-` | Project Initialization | Scaffold new NestJS apps with official CLI commands before applying conventions. |
| `security-` | Security and Throttling | Apply default HTTP hardening and rate limits. |
| `swagger-` | Swagger OpenAPI | Generate protected API docs with bearer auth metadata. |
| `testing-` | Testing | Cover services, guards, and HTTP behavior with focused tests. |
| `tooling-` | TypeScript Tooling | Keep strict TypeScript, ESLint, Prettier, and generated code conventions. |

Add new sections only when several rules share the same concern.

# app-bootstrap

## Use When

- Editing `src/main.ts`.
- Adding global middleware, pipes, Swagger, CORS, or application startup logic.
- Creating a new NestJS API entrypoint.

## Rule

Keep bootstrap explicit and split platform setup into small local functions.
Create the app with `rawBody: true`, enable Helmet, global validation, CORS,
protected Swagger, then listen on `0.0.0.0`.

## Prefer

```ts
const app = await NestFactory.create(AppModule, { rawBody: true });
const logger = new Logger("Bootstrap");

enableHelmet(app, logger);
enableValidation(app, logger);
enableCors(app, logger);

const swaggerPath = enableSwagger(app, logger);
await listen(app, swaggerPath, logger);
```

## Avoid

```ts
const app = await NestFactory.create(AppModule);
app.enableCors();
await app.listen(3000);
```

## Notes

- Keep `rawBody: true` for future webhook signature verification.
- Use `ValidationPipe` with `whitelist`, `forbidNonWhitelisted`, and
  `transform`.
- Read CORS origins from comma-separated `CORS_ORIGIN`.
- Log enabled infrastructure and final URLs through Nest `Logger`.
- Catch fatal bootstrap errors, log them, and exit with code `1`.

# decorators

## Use When

- Marking routes as authenticated or public.
- Reusing Swagger metadata with guards.
- Reading authenticated OIDC subject from controller handlers.
- Standardizing controller tags.

## Rule

Wrap repeated Nest guard and Swagger metadata in small decorators under
`src/common`. Controllers should use these decorators instead of repeating
`UseGuards`, `ApiBearerAuth`, or metadata keys inline.

## Prefer

```ts
@Authenticated()
@Get("me")
getMe(@AuthenticatedOidcSubject() subject: string) {
  return this.usersService.getBySubject(subject);
}
```

```ts
export function Authenticated() {
  return applyDecorators(
    ApiBearerAuth("access-token"),
    ApiUnauthorizedResponse({ description: "Unauthorized" }),
    UseGuards(JwtAuthGuard),
  );
}
```

## Avoid

```ts
@UseGuards(AuthGuard("jwt"))
@ApiBearerAuth()
@Get("me")
getMe(@Req() request: Request) {
  return request.user;
}
```

## Notes

- Use `@Public()` metadata for routes that bypass JWT auth.
- Use a local `Controller(name)` wrapper to pair Nest controller paths with
  Swagger tags.
- Keep metadata constants exported from shared modules instead of hard-coding
  strings in several files.

# dto-validation

## Use When

- Creating DTOs for request bodies, query params, route params, or env config.
- Accepting external input at controller boundaries.
- Adding validation errors or request transformation.

## Rule

Validate inbound HTTP data with Nest DTOs and the global `ValidationPipe`.
Keep DTOs explicit and let controllers receive typed, transformed values.

## Prefer

```ts
export class CreateProjectDto {
  @IsString()
  @IsNotEmpty()
  name!: string;
}
```

```ts
@Post()
create(@Body() input: CreateProjectDto) {
  return this.projectsService.create(input);
}
```

## Avoid

```ts
@Post()
create(@Body() body: any) {
  return this.projectsService.create(body);
}
```

## Notes

- The global pipe should use `whitelist`, `forbidNonWhitelisted`, and
  `transform`.
- Use `class-validator` and `class-transformer` when following this boilerplate.
- Validate data again at non-HTTP trust boundaries when needed, such as webhook
  payloads, job payloads, or third-party responses.

# env-validation

## Use When

- Adding or changing environment variables.
- Reading configuration at startup or inside services.
- Creating `env.example`.

## Rule

Validate environment variables at startup through `ConfigModule.forRoot` and a
typed validation function. Required variables must fail startup with a readable
error.

## Prefer

```ts
ConfigModule.forRoot({
  isGlobal: true,
  validate: validateEnv,
});
```

```ts
class EnvVariables {
  @IsString()
  @IsNotEmpty()
  DATABASE_URL!: string;
}
```

## Avoid

```ts
const databaseUrl = process.env.DATABASE_URL!;
```

## Notes

- Keep `DATABASE_URL`, `ACCEPTED_ISSUERS`, and `ACCEPTED_ALGORITHMS` required.
- Trim comma-separated auth config before use.
- Document every variable in `env.example` with required/optional status and
  default behavior.
- It is acceptable for low-level services such as `PrismaService` to re-check
  critical env vars before connecting.

# error-contract

## Use When

- Adding global filters.
- Changing API error response bodies.
- Handling expected HTTP exceptions.

## Rule

Register a global `HttpExceptionFilter` through `APP_FILTER`. Keep HTTP error
responses predictable and small.

## Prefer

```ts
{
  provide: APP_FILTER,
  useClass: HttpExceptionFilter,
}
```

```ts
response.status(status).json({
  statusCode: status,
  timestamp: new Date().toISOString(),
  path: request.url,
});
```

## Avoid

```ts
throw new Error("not found");
```

## Notes

- Use Nest HTTP exceptions such as `UnauthorizedException`,
  `ForbiddenException`, `BadRequestException`, and `NotFoundException`.
- Do not leak stack traces, provider metadata, JWT internals, or database errors
  in HTTP responses.
- Add fields to the error contract only when clients need them.

# helpers

## Use When

- Repeating small date formatting, timestamp conversion, or authenticated-user
  claim extraction.
- Mapping optional strings from external identity providers.
- Adding utility code that several modules need.

## Rule

Keep helpers small, typed, and boring. Prefer pure functions or static helpers
for deterministic transformations; avoid broad utility modules.

## Prefer

```ts
export function getAuthenticatedOidcSubject(user: unknown) {
  const subject =
    user && typeof user === "object" ? (user as { sub?: unknown }).sub : null;

  if (typeof subject !== "string" || subject.length === 0) {
    throw new UnauthorizedException("Authenticated user subject is missing");
  }

  return subject;
}
```

## Avoid

```ts
export function getUser(user: any) {
  return user.sub;
}
```

## Notes

- Return `null` for absent optional profile fields and throw for missing
  required authenticated subject.
- For date-only strings, use `YYYY-MM-DD` formatting and parse invalid input to
  `null`.
- Keep helper names specific to their domain.

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

# oidc-jwt-auth

## Use When

- Adding authentication to routes.
- Validating bearer access tokens.
- Integrating an OIDC provider.
- Reading authenticated user profile claims.

## Rule

Use OIDC discovery and JWKS to validate JWT bearer tokens. Accept only configured
issuers, audiences, and algorithms. Sync basic OIDC profile fields to the local
database after successful validation.

## Prefer

```ts
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly authService: AuthService) {
    super({
      algorithms: authService.getAcceptedAlgorithms(),
      audience: authService.getAudiences(),
      issuer: authService.getAcceptedIssuers(),
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKeyProvider: (_request, rawToken, done) => {
        authService.getSigningKeyForToken(rawToken).then(
          (key) => done(null, key),
          (error) => done(error),
        );
      },
    });
  }
}
```

## Avoid

```ts
JwtModule.register({
  secret: process.env.JWT_SECRET,
});
```

## Notes

- Normalize issuers by removing trailing slashes before comparison.
- Cache OIDC discovery promises by issuer and JWKS clients by `jwks_uri`.
- Configure JWKS cache and rate limiting.
- Throw `UnauthorizedException` for missing issuer, unaccepted issuer, discovery
  mismatch, missing `jwks_uri`, invalid token, or signing-key resolution failure.
- Store local users by `oidcSubject`; update email, display name, image URL, and
  `lastSeenAt` on each authenticated request.

# permissions

## Use When

- Adding authorization beyond authentication.
- Protecting routes by user capability, object, namespace, or relation.
- Modeling admin/write/read access.

## Rule

Use relation-style permission requirements with `namespace`, `object`, and
`relation`. Route handlers declare requirements with `@RequirePermissions`, and
`PermissionsGuard` checks grants for the authenticated OIDC subject.

## Prefer

```ts
@RequirePermissions({
  namespace: "settings",
  object: "*",
  relation: "read",
})
@Get("settings")
findSettings() {
  return this.settingsService.findAll();
}
```

## Avoid

```ts
if (user.role !== "admin") {
  throw new ForbiddenException();
}
```

## Notes

- Store permission subjects as `oidc:${subject}`.
- Support wildcard object access with `*`.
- Treat `manage` as granting `write` and `read`; treat `write` as granting
  `read`.
- Return `ForbiddenException("Insufficient permissions")` when requirements are
  not met.
- Keep the permission comparison logic as a pure function so it is easy to test.

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

# project-initialization

## Use When

- Creating a new NestJS API from scratch.
- Initializing a backend project before applying this boilerplate.
- Replacing a hand-written NestJS starter scaffold.

## Rule

Use the official Nest CLI to scaffold new NestJS projects, then apply boilerplate
conventions. Do not manually create the initial NestJS project structure when
the official CLI can do it.

Use `--strict` for new TypeScript projects unless the user or target repository
requires a looser configuration.

## Prefer

```bash
npm i -g @nestjs/cli
nest new project-name --strict
```

## Avoid

```bash
mkdir project-name
touch package.json nest-cli.json src/main.ts src/app.module.ts
```

## Notes

- Prefer the package manager already used by the workspace when the Nest CLI
  asks which package manager to use.
- After scaffolding, apply this boilerplate's Prisma, env validation, auth,
  permissions, Swagger, security, and testing rules.
- If the official Nest initializer changes, follow the current official NestJS
  docs over the examples in this rule.

# security-throttling

## Use When

- Creating or reviewing global API security behavior.
- Adding CORS, Helmet, rate limiting, auth bypasses, or public routes.
- Changing `AppModule` providers.

## Rule

Enable secure defaults globally: Helmet, explicit CORS origins, global request
validation, and throttling through `APP_GUARD`. Public routes must opt out
deliberately.

## Prefer

```ts
ThrottlerModule.forRoot([
  {
    ttl: (Number(process.env.THROTTLE_TTL_SECONDS) || 60) * 1000,
    limit: Number(process.env.THROTTLE_LIMIT) || 20,
  },
]);
```

```ts
{
  provide: APP_GUARD,
  useClass: ThrottlerGuard,
}
```

## Avoid

```ts
app.enableCors({ origin: true });
```

## Notes

- Parse CORS origins from a comma-separated `CORS_ORIGIN` string.
- Keep `credentials: true` only with explicit origins.
- Use `@Public()` sparingly and only when the route must bypass auth.
- Keep throttling defaults documented in `env.example`.

# swagger-openapi

## Use When

- Adding or changing API docs.
- Creating controllers, DTOs, or auth decorators.
- Exposing Swagger in development or deployed environments.

## Rule

Use `@nestjs/swagger` for OpenAPI metadata and protect both Swagger UI and the
JSON document with basic auth. Configure bearer auth under the name
`access-token` so route decorators can reference it consistently.

Keep Swagger setup in a dedicated bootstrap helper. Do not expose unprotected
docs from `main.ts`, even in non-production environments.

## Prefer

```ts
const config = new DocumentBuilder()
  .setTitle("API")
  .setDescription("API documentation")
  .setVersion("1.0")
  .addBearerAuth(
    {
      bearerFormat: "JWT",
      scheme: "bearer",
      type: "http",
    },
    "access-token",
  )
  .build();
```

## Avoid

```ts
SwaggerModule.setup("docs", app, document);
```

## Notes

- Protect both `/${SWAGGER_PATH}` and `/${SWAGGER_PATH}-json`.
- Read `SWAGGER_PATH`, `SWAGGER_USERNAME`, and `SWAGGER_PASSWORD` from env with
  documented defaults.
- Pair authenticated routes with `ApiBearerAuth("access-token")` through the
  shared `@Authenticated()` decorator.
- Use a controller wrapper to keep `ApiTags` aligned with controller paths.
- Add `@ApiOperation`, success responses, and expected error responses for
  public endpoints and non-obvious authenticated routes.
- Document request and response DTOs with `@ApiProperty` or
  `@ApiPropertyOptional` when TypeScript metadata is not enough, especially for
  arrays, enums, examples, nullable fields, and nested objects.
- Prefer explicit response DTO classes over leaking Prisma models or internal
  service return types into the public API contract.
- Keep summaries and descriptions short, user-facing, and stable. Avoid
  documenting implementation details, secrets, internal identifiers, or
  temporary rollout behavior.

# testing

## Use When

- Adding services, guards, decorators, permission logic, auth behavior, or
  controllers.
- Fixing bugs in security, persistence, or request validation.
- Changing global filters, pipes, or bootstrap behavior.

## Rule

Use focused Jest tests for pure logic and services, and Supertest e2e tests for
HTTP behavior. Increase test breadth when changing auth, permissions, env
validation, Prisma lifecycle, or global filters.

## Prefer

```ts
describe("doesPermissionGrantAccess", () => {
  it("allows manage to grant read", () => {
    expect(
      doesPermissionGrantAccess({
        grantedObject: "*",
        grantedRelation: "manage",
        requiredObject: "settings",
        requiredRelation: "read",
      }),
    ).toBe(true);
  });
});
```

## Avoid

```ts
it("works", () => {
  expect(true).toBe(true);
});
```

## Notes

- Mock Prisma for unit tests unless the behavior depends on database semantics.
- Use e2e tests for validation pipe behavior, guards, filters, and controller
  responses.
- Keep `test/jest-e2e.json` for e2e config.
- Run at least the relevant Jest target after changing behavior.

# typescript-tooling

## Use When

- Editing TypeScript config, lint config, package scripts, generated clients, or
  imports.
- Adding new scripts for build, format, lint, Prisma, or tests.
- Reviewing type safety.

## Rule

Keep backend TypeScript strict and generated code isolated. Use Prettier,
type-aware ESLint, and pnpm scripts matching the boilerplate.

## Prefer

```json
{
  "scripts": {
    "prebuild": "pnpm prisma:generate",
    "build": "nest build",
    "format:check": "prettier --check \"src/**/*.ts\" \"test/**/*.ts\"",
    "lint": "eslint \"{src,test}/**/*.ts\" --fix",
    "test:e2e": "jest --config test/jest-e2e.json"
  }
}
```

## Avoid

```ts
// eslint-disable-next-line
const value: any = payload;
```

## Notes

- Use `module` and `moduleResolution` set to `nodenext`.
- Keep `strict`, `noImplicitAny`, and decorator metadata enabled.
- Ignore `src/generated/**` in ESLint.
- Treat `@typescript-eslint/no-floating-promises` and
  `@typescript-eslint/no-unsafe-argument` as warnings unless the repo chooses a
  stricter profile.
