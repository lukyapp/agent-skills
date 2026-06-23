# optimistic-updates

## Use When

- A mutation changes data already shown in the UI.
- The UI should feel instant for low-risk actions such as toggles, renames,
  reordering, likes, or simple status changes.
- Refactoring mutation flows that wait for a full refetch before updating.

## Rule

Use TanStack Query optimistic updates only when rollback behavior is clear.
Prefer simple invalidation for complex writes, server-generated data, payments,
permissions, or workflows where a wrong temporary state would be confusing.

## Prefer

```ts
export function useRenameProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: renameProject,
    onMutate: async ({ projectId, name }) => {
      await queryClient.cancelQueries({ queryKey: ["projects"] });

      const previousProjects = queryClient.getQueryData<Project[]>([
        "projects",
      ]);

      queryClient.setQueryData<Project[]>(["projects"], (projects = []) =>
        projects.map((project) =>
          project.id === projectId ? { ...project, name } : project,
        ),
      );

      return { previousProjects };
    },
    onError: (_error, _variables, context) => {
      queryClient.setQueryData(["projects"], context?.previousProjects);
      toast.error("Project could not be renamed");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
    },
  });
}
```

## Avoid

```ts
setProjects((projects) =>
  projects.map((project) =>
    project.id === projectId ? { ...project, name } : project,
  ),
);
```

## Notes

- Snapshot previous cache data in `onMutate`.
- Cancel affected queries before writing optimistic cache data.
- Roll back in `onError`.
- Invalidate or reconcile in `onSettled` or `onSuccess`.
- Keep optimistic cache updates scoped to the affected query keys.
- Do not duplicate server state into Zustand or component state for optimism.
