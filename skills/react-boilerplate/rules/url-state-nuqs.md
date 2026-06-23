# url-state-nuqs

## Use When

- Building search, filters, tabs, pagination, sorting, date ranges, or view
  modes that should survive refresh or be shareable by URL.
- Moving state out of component memory because back/forward navigation matters.

## Rule

Use the repository's URL state helper. Prefer `nuqs` when it is installed.
Avoid hiding shareable view state only in React state.

## Prefer

```tsx
import { parseAsInteger, useQueryState } from "nuqs";

export function ProjectPagination() {
  const [page, setPage] = useQueryState(
    "page",
    parseAsInteger.withDefault(1),
  );

  return (
    <button type="button" onClick={() => setPage(page + 1)}>
      Next
    </button>
  );
}
```

## Avoid

```tsx
const [page, setPage] = useState(1);
```

## Notes

- Keep ephemeral UI state, such as a dropdown being open, out of the URL.
- Include URL state values in React Query keys when they affect fetched data.
- Use typed parsers instead of manual `URLSearchParams` string parsing when the
  project has a helper available.
