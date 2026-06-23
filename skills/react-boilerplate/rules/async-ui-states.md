# async-ui-states

## Use When

- Rendering data loaded from an API.
- Building pages, panels, lists, tables, selects, dashboards, or detail views.
- Handling mutations that can be pending, failed, or successful.

## Rule

Every data-driven UI should represent loading, empty, error, and success states.
Use the repository's skeleton, spinner, alert, empty-state, and toast patterns
when they exist.

## Prefer

```tsx
export function ProjectList() {
  const projectsQuery = useProjects();

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  if (projectsQuery.data.length === 0) {
    return <EmptyState title="No projects yet" />;
  }

  return <ProjectsTable projects={projectsQuery.data} />;
}
```

## Avoid

```tsx
if (!projects) {
  return null;
}
```

## Notes

- Disable submit buttons or show pending state while mutations are running.
- Prefer local retry actions when a failed query can be retried.
- Use optimistic updates only when rollback behavior is clear.
- Do not hide errors silently.
