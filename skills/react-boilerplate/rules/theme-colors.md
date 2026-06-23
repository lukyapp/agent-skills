# theme-colors

## Use When

- Adding or changing light mode, dark mode, theme switching, color tokens, or
  Tailwind color classes.
- Styling user-facing React components with backgrounds, text, borders, rings,
  shadows, accents, or semantic status colors.
- Refactoring hard-coded colors such as `bg-slate-950`, `text-blue-600`,
  `dark:bg-*`, hex values, or one-off CSS variables in components.

## Rule

Use semantic theme tokens instead of hard-coded palette colors. Components
should describe intent with tokens such as `bg-background`, `text-foreground`,
`bg-card`, `border-border`, `text-muted-foreground`, `bg-primary`,
`text-primary-foreground`, `text-error`, `text-warning`, and `text-success`.

Define the real light and dark values once at the theme boundary, usually in
global CSS. In Tailwind v4 projects, expose CSS variables through `@theme
inline` so utilities resolve to the current theme.

## Prefer

```css
@import "tailwindcss";

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-success: var(--success);
  --color-warning: var(--warning);
  --color-error: var(--error);
}

:root,
:root[data-theme="light"] {
  color-scheme: light;
  --background: #f8fafc;
  --foreground: #0f172a;
  --card: #ffffff;
  --card-foreground: #0f172a;
  --primary: #2563eb;
  --primary-foreground: #ffffff;
  --border: #e2e8f0;
  --input: #ffffff;
  --ring: #3b82f6;
  --muted: #f1f5f9;
  --muted-foreground: #64748b;
  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
}

:root[data-theme="dark"] {
  color-scheme: dark;
  --background: #020617;
  --foreground: #e5e7eb;
  --card: #0f172a;
  --card-foreground: #e5e7eb;
  --primary: #60a5fa;
  --primary-foreground: #0f172a;
  --border: #1e293b;
  --input: #0f172a;
  --ring: #60a5fa;
  --muted: #1e293b;
  --muted-foreground: #94a3b8;
  --success: #4ade80;
  --warning: #fbbf24;
  --error: #f87171;
}
```

```tsx
export function ProjectCard() {
  return (
    <article className="rounded-lg border border-border bg-card p-4 text-card-foreground shadow-sm shadow-[var(--shadow-color)]">
      <h2 className="text-lg font-semibold text-foreground">Project</h2>
      <p className="text-sm text-muted-foreground">Updated today</p>
      <button className="mt-4 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring">
        Open
      </button>
    </article>
  );
}
```

```tsx
type Theme = "light" | "dark";

function applyTheme(theme: Theme) {
  const root = document.documentElement;
  root.dataset.theme = theme;
  root.style.colorScheme = theme;
  localStorage.setItem("theme", theme);
}
```

## Avoid

```tsx
export function ProjectCard() {
  return (
    <article className="rounded-lg border border-slate-200 bg-white p-4 text-slate-950 shadow-sm dark:border-slate-800 dark:bg-slate-950 dark:text-slate-100">
      <h2 className="text-lg font-semibold text-blue-600 dark:text-blue-300">
        Project
      </h2>
      <p className="text-sm text-slate-500 dark:text-slate-400">
        Updated today
      </p>
    </article>
  );
}
```

```tsx
<div style={{ background: "#020617", color: "#e5e7eb" }} />
```

## Notes

- Keep palette choices centralized. Change color values in the theme, not in
  every component.
- Prefer `data-theme="light"` and `data-theme="dark"` on `documentElement`.
  A `.dark` class is acceptable only when the repository already depends on it.
- Respect `prefers-color-scheme` for the initial theme when no explicit user
  preference exists.
- Persist an explicit user choice in local storage or the repository's existing
  settings store.
- Set `color-scheme` when applying the theme so native form controls, scrollbars,
  and browser UI match.
- Use semantic status tokens for alerts and badges: `success`, `warning`, and
  `error`.
- Use `shadow-[var(--shadow-color)]` or a project shadow token when shadow color
  must change between themes.
- Hard-coded palette colors are acceptable for brand assets, logos, charts, or
  externally mandated colors, but keep them isolated and name why they are not
  theme tokens.
