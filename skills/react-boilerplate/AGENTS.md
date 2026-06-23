# Luky App React Boilerplate

This file is generated from `rules/*.md`.

Use these rules when creating, modifying, or reviewing React, Next.js, or
TypeScript frontend code in projects that should follow Luky app boilerplate
conventions.

Prefer the target repository's existing code first, then these rules when the
repository has no clear precedent.

## Workflow

1. Inspect `package.json` and nearby implementation patterns before editing.
2. Use installed dependencies and local helpers.
3. Keep code typed, direct, and maintainable.
4. Add a new rule when a preference becomes recurring.

# Rule Sections

| Prefix | Section | Purpose |
| --- | --- | --- |
| `library-` | Library Selection | Decide which project dependency or local abstraction to use. |
| `react-query-` | API Calls and Server State | Fetch, cache, mutate, invalidate, and represent remote data. |

Add new sections only when several rules share the same concern.

# library-selection

## Use When

- Creating new React or Next.js code.
- Choosing a package for data fetching, forms, state, validation, tables,
  dates, UI components, styling, icons, or routing.
- Refactoring code that introduced a one-off helper or duplicate abstraction.

## Rule

Use the repository's installed dependencies and established local wrappers
before introducing a new package or pattern.

1. Read `package.json` and nearby code before choosing an implementation.
2. Prefer local helpers such as shared API clients, typed route helpers,
   design-system components, schema utilities, and query key factories.
3. If a preferred library is already installed, use it consistently.
4. If no approved dependency exists, implement the smallest local solution and
   explain when a dependency would become worth adding.
5. Do not add a competing library for the same role without an explicit user
   request.

## Prefer

```tsx
import { Button } from "@/components/ui/button";
import { api } from "@/lib/api";

export function SaveButton() {
  return <Button type="submit">Save</Button>;
}
```

## Avoid

```tsx
export function SaveButton() {
  return <button className="custom-new-button-system">Save</button>;
}
```

## Notes

- Existing repository architecture beats this skill when the repo is more
  specific.
- Add a new rule file when a dependency choice becomes a recurring convention.

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
