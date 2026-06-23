# routing-tanstack-router

## Use When

- Working in a React/Vite app that uses `@tanstack/router` or
  `@tanstack/react-router`.
- Creating routes, links, navigation, route params, loaders, or search params
  outside a Next.js app.
- Refactoring stringly typed navigation in a TanStack Router project.

## Rule

Use TanStack Router's typed route APIs for React/Vite routing. Do not add React
Router or ad hoc route constants to a project that already uses TanStack Router.

## Prefer

```tsx
import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/projects/$projectId")({
  component: ProjectPage,
});

function ProjectPage() {
  const { projectId } = Route.useParams();

  return (
    <Link to="/projects/$projectId/settings" params={{ projectId }}>
      Settings
    </Link>
  );
}
```

## Avoid

```tsx
window.location.href = `/projects/${projectId}/settings`;
```

## Notes

- In Next.js apps, use the repository's Next router conventions instead.
- Validate route search params with the router's search validation pattern,
  commonly with Zod when available.
- Include route params and search params in React Query keys when they affect
  fetched data.
- Keep navigation through `Link`, router hooks, or typed route helpers.
