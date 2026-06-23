# accessibility

## Use When

- Creating forms, buttons, links, dialogs, menus, tabs, tables, icon buttons, or
  custom interactive components.
- Adding validation errors, loading states, keyboard shortcuts, or focus
  management.
- Replacing semantic HTML with custom markup.

## Rule

Prefer semantic HTML and accessible design-system primitives. Every interactive
control must have an accessible name, keyboard behavior, visible focus, and
clear disabled or pending state.

## Prefer

```tsx
export function DeleteProjectButton() {
  const deleteProject = useDeleteProject();

  return (
    <button
      type="button"
      aria-label="Delete project"
      disabled={deleteProject.isPending}
      onClick={() => deleteProject.mutate()}
    >
      <Trash aria-hidden="true" />
    </button>
  );
}
```

```tsx
<label htmlFor="project-name">Name</label>
<input
  id="project-name"
  aria-invalid={Boolean(error)}
  aria-describedby={error ? "project-name-error" : undefined}
/>
{error ? <p id="project-name-error">{error.message}</p> : null}
```

## Avoid

```tsx
<div onClick={onSave}>Save</div>
<button><Trash /></button>
```

## Notes

- Use `button` for actions and links for navigation.
- Provide `aria-label` for icon-only buttons.
- Mark decorative icons with `aria-hidden="true"`.
- Keep focus trapped in dialogs and return focus after close when the design
  system does not handle it.
- Do not remove focus outlines without replacing them with a visible focus
  style.
- Associate form errors with fields using `aria-describedby`.
- Prefer accessible component primitives for dialogs, menus, popovers, tabs,
  and selects.
