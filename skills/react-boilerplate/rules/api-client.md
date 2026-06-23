# api-client

## Use When

- Adding a new API call.
- Repeating `fetch` options, headers, base URLs, response parsing, or error
  handling.
- Wiring authenticated client requests.

## Rule

Prefer the repository's shared API client. If none exists, create the smallest
typed wrapper before adding more raw `fetch` calls.

The API client should centralize:

- base URL or relative API prefix
- JSON request and response parsing
- auth/session headers when the app uses them
- standard API errors
- request cancellation via `AbortSignal` when useful

## Prefer

```ts
export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export async function apiJson<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(path, {
    ...init,
    headers: {
      "content-type": "application/json",
      ...init?.headers,
    },
  });

  if (!response.ok) {
    throw new ApiError("API request failed", response.status);
  }

  return response.json() as Promise<T>;
}
```

## Avoid

```ts
const response = await fetch("/api/projects");
const projects = await response.json();
```

## Notes

- Do not create a second API abstraction if the repo already has one.
- Keep API functions outside React components.
- Validate untrusted response bodies with Zod when correctness matters.
