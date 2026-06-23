# responsive-mobile

## Use When

- Creating or modifying any user-facing React UI.
- Building pages, dashboards, forms, dialogs, tables, lists, navigation, or
  toolbars.
- Fixing overflow, cramped layouts, hidden controls, or unusable mobile states.

## Rule

Design mobile-first, then enhance for larger screens. Every interactive view
must remain readable, reachable, and usable on narrow screens without horizontal
page overflow.

## Prefer

```tsx
export function ProjectHeader() {
  return (
    <header className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div className="min-w-0">
        <h1 className="truncate text-xl font-semibold sm:text-2xl">
          Projects
        </h1>
        <p className="text-sm text-muted-foreground">
          Manage active client work.
        </p>
      </div>
      <Button className="w-full sm:w-auto">New project</Button>
    </header>
  );
}
```

```tsx
<div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
  {projects.map((project) => (
    <ProjectCard key={project.id} project={project} />
  ))}
</div>
```

## Avoid

```tsx
<div className="flex items-center justify-between">
  <h1>Very long page title that can overflow</h1>
  <button>New project</button>
</div>
```

```tsx
<div className="w-[1200px]">
  ...
</div>
```

## Patterns

- Start with single-column mobile layout.
- Add `sm:`, `md:`, `lg:`, and `xl:` enhancements only when the content needs
  the extra space.
- Use `min-w-0`, `truncate`, `break-words`, or wrapping where long text can
  appear.
- Prefer `w-full sm:w-auto` for primary actions in narrow containers.
- Keep tap targets comfortably clickable, normally at least 40px tall.
- Use responsive gaps and padding instead of fixed desktop spacing everywhere.
- Avoid fixed pixel widths for containers. Prefer `max-w-*`, grids, flex wrap,
  and fluid widths.

## Tables and Lists

- Do not squeeze wide desktop tables into unreadable mobile tables.
- For small datasets, switch to stacked cards on mobile when that is clearer.
- For dense admin tables, use horizontal overflow on the table container, not
  the page.
- Keep filters and search controls usable as stacked mobile controls.

```tsx
<div className="overflow-x-auto">
  <Table className="min-w-[720px]">...</Table>
</div>
```

## Dialogs and Drawers

- Use full-width or near-full-width dialogs on mobile.
- Keep destructive actions visible without requiring awkward horizontal
  scrolling.
- Ensure modal content can scroll when the viewport is short.
- Prefer drawers/sheets for mobile flows when the repository already uses them.

## Verification

Before finishing meaningful UI work, inspect at least:

- mobile width around 375px
- tablet width around 768px when layout changes there
- desktop width around 1280px

Check for:

- horizontal page overflow
- clipped text or buttons
- unreachable actions
- broken dialogs/popovers
- tables that cannot be read or scrolled
- focus states and keyboard navigation still working

## Notes

- Follow existing design-system responsive conventions first.
- Responsive behavior should not duplicate business logic across mobile and
  desktop components unless the layouts are genuinely different.
- Keep desktop density where it helps, but never at the cost of mobile
  usability.
