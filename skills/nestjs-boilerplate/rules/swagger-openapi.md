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
