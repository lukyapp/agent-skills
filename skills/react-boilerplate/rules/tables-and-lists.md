# tables-and-lists

## Use When

- Building collection views, tables, cards, grids, search results, or admin
  lists.
- Adding filters, sorting, pagination, row actions, selection, or bulk actions.
- Refactoring local-only list state that should be shareable or cached.

## Rule

Drive list data from URL state plus TanStack Query. Use TanStack Table when the
table needs sorting, column definitions, row selection, visibility, or complex
cell rendering. Keep simple lists simple.

## Prefer

```tsx
export function ProjectListPage() {
  const [page] = useQueryState("page", parseAsInteger.withDefault(1));
  const [search] = useQueryState("search", parseAsString.withDefault(""));

  const projectsQuery = useProjects({
    page,
    search,
  });

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  if (projectsQuery.data.items.length === 0) {
    return <EmptyState title="No projects found" />;
  }

  return (
    <ProjectsTable
      projects={projectsQuery.data.items}
      pageCount={projectsQuery.data.pageCount}
    />
  );
}
```

```ts
export function useProjects(params: { page: number; search: string }) {
  return useQuery({
    queryKey: ["projects", params],
    queryFn: () => listProjects(params),
  });
}
```

## Avoid

```tsx
const [page, setPage] = useState(1);
const [projects, setProjects] = useState([]);
```

## Notes

- Put filters, sort, search, pagination, and view mode in URL state when users
  should be able to refresh, share, or navigate back to the same view.
- Include every list parameter that affects server data in the React Query key.
- Prefer server-side pagination/filtering for large or remote datasets.
- Keep destructive row actions behind confirmations.
- Preserve loading, empty, error, and success states.
- Use stable row IDs for table selection and optimistic updates.
