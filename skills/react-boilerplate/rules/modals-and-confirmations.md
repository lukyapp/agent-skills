# modals-and-confirmations

## Use When

- Adding dialogs, drawers, sheets, command menus, or confirmation prompts.
- Confirming destructive actions such as delete, revoke, archive, reset, or
  remove access.
- Placing forms inside modals or drawers.

## Rule

Use the repository's accessible dialog primitives. Destructive actions require a
clear confirmation step, pending state, and safe close behavior.

## Prefer

```tsx
export function DeleteProjectDialog({ projectId }: { projectId: string }) {
  const [open, setOpen] = useState(false);
  const deleteProject = useDeleteProject();

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button type="button" variant="destructive">
          Delete
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete project?</DialogTitle>
          <DialogDescription>
            This action cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            disabled={deleteProject.isPending}
            onClick={() => setOpen(false)}
          >
            Cancel
          </Button>
          <Button
            type="button"
            variant="destructive"
            disabled={deleteProject.isPending}
            onClick={() =>
              deleteProject.mutate(
                { projectId },
                { onSuccess: () => setOpen(false) },
              )
            }
          >
            Delete
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

## Avoid

```tsx
if (window.confirm("Delete?")) {
  deleteProject.mutate({ projectId });
}
```

## Notes

- Prefer design-system dialog components that handle focus trap and aria
  attributes.
- Keep destructive copy explicit about what will be deleted or changed.
- Disable close/cancel buttons only when closing would corrupt a critical
  in-flight flow; otherwise keep escape routes available.
- Close the modal after successful mutations, not before.
- Show form validation errors inside the dialog.
- Return focus to the trigger after close when the primitive does not handle it.
