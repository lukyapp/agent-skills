# domain-feature-structure

## Use When

- Adding a new feature, route, hook, API integration, form, or state flow.
- Creating files for a business concept such as projects, users, billing,
  organizations, teams, subscriptions, reports, or settings.
- Refactoring code that mixes API calls, UI state, business rules, and rendering
  in the same component.

## Rule

Organize application code by business domain first. Keep a light hexagonal
architecture: domain code has no React dependency, application code expresses
use cases, infrastructure code talks to external systems, and UI code renders
and wires hooks.

## Preferred Shape

Use the repository's existing root folders. When no convention exists, prefer a
domain-first structure like this:

```text
src/
  domains/
    projects/
      domain/
        project.ts
        project-rules.ts
      application/
        project-queries.ts
        project-mutations.ts
        project-use-cases.ts
      infrastructure/
        project-api.ts
        project-schemas.ts
      ui/
        project-form.tsx
        project-list.tsx
        project-empty-state.tsx
      index.ts
```

For route-first frameworks such as Next.js App Router, keep route files thin and
delegate to domains:

```text
src/
  app/
    projects/
      page.tsx
      loading.tsx
      error.tsx
  domains/
    projects/
      ...
```

## Layer Responsibilities

`domain/`

- Put business types, entities, value objects, and pure rules here.
- Do not import React, TanStack Query, fetch clients, router APIs, or UI
  components.
- Keep code deterministic and easy to unit test.

`application/`

- Put use cases, query hooks, mutation hooks, orchestration, and app-specific
  workflows here.
- Use TanStack Query from this layer when creating React-facing hooks.
- Depend on `domain/` and `infrastructure/`, not on presentational UI.

`infrastructure/`

- Put API clients, Zod transport schemas, adapters, storage, analytics, and
  third-party SDK calls here.
- Convert external data into domain/application shapes.
- Keep raw HTTP details out of components.

`ui/`

- Put React components, forms, dialogs, tables, and view models here.
- Components may call application hooks.
- Keep business rules out of JSX when they can live in `domain/` or
  `application/`.

## Dependency Direction

Follow this direction:

```text
ui -> application -> domain
ui -> application -> infrastructure -> domain
```

Avoid these imports:

```text
domain -> ui
domain -> infrastructure
infrastructure -> ui
```

## Prefer

```tsx
// domains/projects/ui/project-list.tsx
export function ProjectList() {
  const projectsQuery = useProjects();

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  return <ProjectsTable projects={projectsQuery.data} />;
}
```

```ts
// domains/projects/application/project-queries.ts
export function useProjects() {
  return useQuery({
    queryKey: ["projects"],
    queryFn: listProjects,
  });
}
```

```ts
// domains/projects/infrastructure/project-api.ts
export async function listProjects() {
  const data = await apiJson<unknown>("/api/projects");
  return projectListSchema.parse(data);
}
```

## Avoid

```tsx
export function ProjectsPage() {
  const [projects, setProjects] = useState([]);

  useEffect(() => {
    fetch("/api/projects")
      .then((response) => response.json())
      .then((data) => {
        if (data.length > 10) {
          data.sort();
        }

        setProjects(data);
      });
  }, []);

  return <div>{JSON.stringify(projects)}</div>;
}
```

## Notes

- Do not over-split tiny features. Start with fewer files and create layers when
  the code has a real responsibility to isolate.
- Prefer domain names over technical names. Use `projects`, not `api` or
  `components`, as the main grouping.
- Shared generic UI remains in the app's design-system folders. Domain-specific
  UI stays in the domain.
- Cross-domain code should be explicit. If two domains need the same concept,
  extract a small shared kernel only after duplication is real.
- Keep barrel exports narrow. Do not export infrastructure internals from a
  public domain index unless another domain is meant to depend on them.
