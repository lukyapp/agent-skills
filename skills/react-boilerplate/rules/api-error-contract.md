# api-error-contract

## Use When

- Creating or consuming API routes, server actions, or client API wrappers.
- Mapping API failures to forms, toasts, inline errors, or error boundaries.
- Replacing inconsistent error shapes such as strings, HTML, or arbitrary JSON.

## Rule

Use a stable API error contract. Client code should be able to distinguish
global errors from field errors and authorization errors without parsing message
strings.

## Preferred Shape

```ts
export type ApiErrorCode =
  | "BAD_REQUEST"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "NOT_FOUND"
  | "VALIDATION_ERROR"
  | "CONFLICT"
  | "INTERNAL_ERROR";

export type ApiErrorBody = {
  error: {
    code: ApiErrorCode;
    message: string;
    fieldErrors?: Record<string, string[]>;
  };
};
```

## Prefer

```ts
export function validationError(
  fieldErrors: Record<string, string[]>,
): Response {
  return Response.json(
    {
      error: {
        code: "VALIDATION_ERROR",
        message: "Please check the highlighted fields.",
        fieldErrors,
      },
    } satisfies ApiErrorBody,
    { status: 422 },
  );
}
```

```ts
if (error instanceof ApiError && error.code === "VALIDATION_ERROR") {
  applyFieldErrors(form, error.fieldErrors);
  return;
}

toast.error(getApiErrorMessage(error));
```

## Avoid

```ts
return Response.json({ message: "nope" }, { status: 400 });
```

```ts
if (error.message.includes("validation")) {
  // ...
}
```

## Notes

- Use HTTP status for transport meaning and `error.code` for app meaning.
- Use `422` for validation errors when the backend supports it.
- Do not leak internal exception messages to users.
- Keep user-facing messages short and translatable in localized apps.
- Prefer field errors for form validation and toast/global errors for
  non-field failures.
- Update `api-client.md` behavior when introducing or changing the error class.
