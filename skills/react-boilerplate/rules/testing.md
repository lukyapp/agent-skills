# testing

## Use When

- Adding behavior with meaningful branching, validation, server state, routing,
  auth, or user flows.
- Fixing a bug that can regress.
- Creating reusable hooks, API helpers, schemas, or UI state stores.

## Rule

Choose the smallest test type that proves the behavior.

- Use Vitest or the repository's unit test runner for pure functions, schemas,
  query helpers, stores, and utilities.
- Use Testing Library for component behavior and accessible user interactions.
- Use MSW when tests need API behavior without real network calls.
- Use Playwright for critical browser flows, routing, forms, auth, and
  cross-page behavior.

## Prefer

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

it("submits valid project values", async () => {
  const user = userEvent.setup();
  render(<ProjectForm />);

  await user.type(screen.getByLabelText("Name"), "Launch");
  await user.click(screen.getByRole("button", { name: "Save" }));

  expect(await screen.findByText("Saved")).toBeInTheDocument();
});
```

## Avoid

```tsx
it("renders", () => {
  render(<ProjectForm />);
});
```

## Notes

- Prefer assertions visible to users over implementation details.
- Keep mocks close to the behavior under test.
- Do not add a second test framework when one already exists.
- For new helpers in this skill repository, run the deterministic script or
  parser directly when possible.
