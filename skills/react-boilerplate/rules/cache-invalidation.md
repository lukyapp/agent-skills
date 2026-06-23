# cache-invalidation

## Use When

- Adding React Query mutations.
- Designing query keys for lists, details, counts, dashboards, or search pages.
- Fixing stale UI after create, update, delete, upload, or reorder actions.

## Rule

Define stable query keys and invalidate the smallest useful cache scope after
mutations. Prefer feature-level query key helpers when a domain has more than
one query.

## Prefer

```ts
export const projectKeys = {
  all: ["projects"] as const,
  lists: () => [...projectKeys.all, "list"] as const,
  list: (params: ProjectListParams) => [...projectKeys.lists(), params] as const,
  detail: (projectId: string) => [...projectKeys.all, "detail", projectId] as const,
};
```

```ts
export function useUpdateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updateProject,
    onSuccess: (project) => {
      queryClient.setQueryData(projectKeys.detail(project.id), project);
      queryClient.invalidateQueries({ queryKey: projectKeys.lists() });
    },
  });
}
```

## Avoid

```ts
queryClient.invalidateQueries();
```

```ts
useQuery({ queryKey: ["data"], queryFn: listProjects });
```

## Notes

- Include every parameter that affects fetched data in the query key.
- Use list/detail key helpers for domains with multiple queries.
- After create: usually invalidate lists.
- After update: update detail cache and invalidate affected lists.
- After delete: remove or invalidate detail cache and invalidate affected lists.
- After upload: invalidate the entity detail and any asset/list queries that
  render the uploaded file.
- Use optimistic updates only when rollback behavior is clear.
