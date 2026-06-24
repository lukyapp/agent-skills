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
