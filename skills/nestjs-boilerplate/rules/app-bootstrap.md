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
