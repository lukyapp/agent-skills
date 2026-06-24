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
