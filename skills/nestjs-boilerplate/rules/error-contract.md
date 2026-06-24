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
