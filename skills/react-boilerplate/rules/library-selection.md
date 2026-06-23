# library-selection

## Use When

- Creating new React or Next.js code.
- Choosing a package for data fetching, forms, state, validation, tables,
  dates, UI components, styling, icons, or routing.
- Refactoring code that introduced a one-off helper or duplicate abstraction.

## Rule

Use the repository's installed dependencies and established local wrappers
before introducing a new package or pattern.

1. Read `package.json` and nearby code before choosing an implementation.
2. Prefer local helpers such as shared API clients, typed route helpers,
   design-system components, schema utilities, and query key factories.
3. If a preferred library is already installed, use it consistently.
4. If no approved dependency exists, implement the smallest local solution and
   explain when a dependency would become worth adding.
5. Do not add a competing library for the same role without an explicit user
   request.

## Prefer

```tsx
import { Button } from "@/components/ui/button";
import { api } from "@/lib/api";

export function SaveButton() {
  return <Button type="submit">Save</Button>;
}
```

## Avoid

```tsx
export function SaveButton() {
  return <button className="custom-new-button-system">Save</button>;
}
```

## Notes

- Existing repository architecture beats this skill when the repo is more
  specific.
- Add a new rule file when a dependency choice becomes a recurring convention.
