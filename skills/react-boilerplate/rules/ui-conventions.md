# ui-conventions

## Use When

- Adding buttons, inputs, dialogs, icons, toasts, layouts, dates, or visual
  states.
- Choosing between custom markup and existing UI primitives.

## Rule

Use the repository's design system and UI utilities before creating new visual
primitives.

Preferred defaults when available:

- `shadcn/ui` or local design-system components for common UI primitives
- Tailwind utilities for styling in Tailwind projects
- `clsx` plus `tailwind-merge` or the repo's `cn` helper for class composition
- `lucide-react` for icons
- the repo's toast system, commonly `sonner`, for transient feedback
- one date library only, commonly `date-fns` or the library already installed

## Prefer

```tsx
import { Plus } from "lucide-react";

import { Button } from "@/components/ui/button";

export function NewProjectButton() {
  return (
    <Button type="button">
      <Plus aria-hidden="true" />
      New project
    </Button>
  );
}
```

## Avoid

```tsx
export function NewProjectButton() {
  return <button className="my-new-button">+ New project</button>;
}
```

## Notes

- Match existing component imports and aliases.
- Do not introduce a second icon, toast, date, or styling system.
- Keep accessibility attributes intact when composing UI primitives.
- Use visible text for user-facing labels and icons as decoration unless the
  icon-only control has an accessible label.
