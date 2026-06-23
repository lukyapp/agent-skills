# dates-date-fns

## Use When

- Formatting dates or times.
- Comparing dates, adding durations, calculating ranges, or grouping by day.
- Replacing hand-written date string manipulation.

## Rule

Use the repository's existing date library. Prefer `date-fns` for new date
helpers when no project standard exists. Do not mix `date-fns`, `dayjs`,
`moment`, and custom date helpers in the same app without an explicit reason.

## Prefer

```ts
import { format, parseISO } from "date-fns";

export function formatProjectDate(value: string) {
  return format(parseISO(value), "MMM d, yyyy");
}
```

## Avoid

```ts
export function formatProjectDate(value: string) {
  return value.split("T")[0];
}
```

## Notes

- Keep API transport dates as ISO strings unless the repo has a stronger
  convention.
- Parse at the edge of display or calculation.
- Be explicit about timezone-sensitive behavior.
- Use `Intl.DateTimeFormat` when the app needs locale-aware formatting and the
  existing pattern already uses platform APIs.
