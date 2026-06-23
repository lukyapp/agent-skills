# i18n-next-intl

## Use When

- Adding or changing user-facing copy in a Next.js app that uses `next-intl`.
- Creating pages, metadata, forms, validation messages, navigation labels, or
  empty/error states that need translation.
- Refactoring inline strings in localized routes.

## Rule

Use `next-intl` and the repository's message files for user-facing copy. Do not
create local copy objects, inline dictionaries, or parallel translation systems.

## Prefer

```tsx
import { useTranslations } from "next-intl";

export function ProjectEmptyState() {
  const t = useTranslations("Projects.empty");

  return (
    <section>
      <h2>{t("title")}</h2>
      <p>{t("description")}</p>
    </section>
  );
}
```

## Avoid

```tsx
const copy = {
  title: "No projects yet",
  description: "Create your first project to get started.",
};
```

## Notes

- Also use the `lukyapp-repo-i18n` skill when changing locale files or i18n
  architecture in this repository family.
- Add copy to the source locale first.
- Preserve ICU placeholders and variable names across translations.
- Keep translation keys stable and feature-scoped.
- Use server-side `getTranslations` in server components, route metadata, and
  server-only code when that matches the existing app pattern.
