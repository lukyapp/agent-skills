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
