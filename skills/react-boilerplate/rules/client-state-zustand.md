# client-state-zustand

## Use When

- Managing client-only global state such as open panels, selected local UI
  items, optimistic drafts, command palette state, or feature tour progress.
- Replacing prop drilling for UI state that is not server data.

## Rule

Use Zustand for simple client-only global state when local component state or
context would become awkward. Do not use Zustand as a replacement for TanStack
Query server state.

## Prefer

```ts
import { create } from "zustand";

type SidebarState = {
  isOpen: boolean;
  setOpen: (isOpen: boolean) => void;
};

export const useSidebarStore = create<SidebarState>((set) => ({
  isOpen: false,
  setOpen: (isOpen) => set({ isOpen }),
}));
```

## Avoid

```ts
const useProjectStore = create((set) => ({
  projects: [],
  loadProjects: async () => {
    const projects = await fetch("/api/projects").then((res) => res.json());
    set({ projects });
  },
}));
```

## Notes

- Prefer component state for state used by one component subtree.
- Prefer URL state for shareable filters, tabs, search, pagination, and sort.
- Keep store actions small and explicit.
- Add persistence only when the product needs state to survive reloads.
