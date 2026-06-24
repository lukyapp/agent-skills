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
