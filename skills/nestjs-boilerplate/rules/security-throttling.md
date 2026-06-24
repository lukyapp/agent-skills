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
