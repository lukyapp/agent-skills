# routing-structured-pages

## Use When

- Creating pages, routes, links, navigation, route params, loaders, or search
  params.
- Splitting a multi-view feature into distinct user-facing screens.
- Refactoring stringly typed navigation or ad hoc view switches.

## Rule

Use the repository's existing router and create distinct pages/routes for
distinct user-facing screens. The goal is structured navigation, not forcing a
specific routing library.

Do not replace the installed router just to follow this rule. In React Router
projects, add React Router routes and links. In TanStack Router projects, use
TanStack Router's typed route APIs. In Next.js apps, follow the repository's
Next router conventions.

## Prefer

React Router project:

```tsx
import { Link, useParams } from "react-router-dom";

export function ProjectPage() {
  const { projectId } = useParams();

  return <Link to={`/projects/${projectId}/settings`}>Settings</Link>;
}
```

TanStack Router project:

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
// Route-worthy screens hidden behind local state.
const [activeView, setActiveView] = useState<"details" | "settings">(
  "details",
);
```

## Notes

- Keep route files thin. Put page composition in page components and business
  logic in domain/application hooks or services.
- Use tabs or local state for small view modes inside one page; use routes for
  screens users should bookmark, share, open directly, or navigate between.
- Validate route search params with the router's validation pattern, commonly
  with Zod when available.
- Include route params and search params in React Query keys when they affect
  fetched data.
- Keep navigation through `Link`, router hooks, or typed route helpers.
