# react-query-api-calls

## Use When

- Fetching data from the app API in React components or hooks.
- Creating mutations for create, update, delete, upload, or command actions.
- Handling loading, error, retry, cache, optimistic updates, or invalidation.
- Replacing ad hoc `useEffect` plus `fetch` server-state code.

## Rule

Use TanStack Query, commonly imported from `@tanstack/react-query`, for client
API calls and server state. Do not use component-local `useEffect` and
`useState` as the primary fetching mechanism for API data.

## Query Pattern

Create typed API functions outside components, then consume them through
`useQuery`.

```tsx
import { useQuery } from "@tanstack/react-query";

type Project = {
  id: string;
  name: string;
};

async function listProjects(): Promise<Project[]> {
  const response = await fetch("/api/projects");

  if (!response.ok) {
    throw new Error("Failed to load projects");
  }

  return response.json();
}

export function useProjects() {
  return useQuery({
    queryKey: ["projects"],
    queryFn: listProjects,
  });
}
```

## Mutation Pattern

Use `useMutation` for writes and invalidate or update affected queries after a
successful mutation.

```tsx
import { useMutation, useQueryClient } from "@tanstack/react-query";

type CreateProjectInput = {
  name: string;
};

async function createProject(input: CreateProjectInput) {
  const response = await fetch("/api/projects", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

  if (!response.ok) {
    throw new Error("Failed to create project");
  }

  return response.json();
}

export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createProject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
    },
  });
}
```

## Avoid

```tsx
import { useEffect, useState } from "react";

export function Projects() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/projects")
      .then((response) => response.json())
      .then(setProjects)
      .finally(() => setLoading(false));
  }, []);

  return null;
}
```

## Notes

- Keep query keys stable, explicit, and colocated with the feature or query
  helper.
- Include all parameters that affect returned data in the query key.
- Use `enabled` for queries that depend on optional values.
- Prefer existing repository API clients over raw `fetch` when they exist.
- Surface errors through the app's existing toast, form, or error-boundary
  pattern instead of inventing a new display system.
