# notifications-sonner

## Use When

- Showing mutation success or failure.
- Reporting background task status.
- Replacing `alert`, inline-only transient feedback, or console-only errors.

## Rule

Use the repository's toast system for transient feedback. Prefer `sonner` when
it is installed and no stronger local wrapper exists.

## Prefer

```tsx
import { toast } from "sonner";

export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createProject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
      toast.success("Project created");
    },
    onError: () => {
      toast.error("Project could not be created");
    },
  });
}
```

## Avoid

```tsx
window.alert("Saved");
```

## Notes

- Do not toast every successful background refresh.
- Prefer field errors for form validation failures.
- Keep toast copy short and user-facing.
- Use the existing app toast wrapper when one exists, especially if it handles
  i18n, logging, or error normalization.
