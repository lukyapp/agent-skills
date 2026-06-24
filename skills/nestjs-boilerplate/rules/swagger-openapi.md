# swagger-openapi

## Use When

- Adding or changing API docs.
- Creating controllers, DTOs, or auth decorators.
- Exposing Swagger in development or deployed environments.

## Rule

Use `@nestjs/swagger` and protect Swagger UI and JSON with basic auth. Configure
bearer auth under the name `access-token` so route decorators can reference it
consistently.

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
