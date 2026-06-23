# validation-zod

## Use When

- Reading form input, URL params, API responses, localStorage, env vars, or
  third-party webhook/client data.
- Defining a contract shared by UI and API code.
- Replacing fragile type assertions on external data.

## Rule

Use Zod at trust boundaries. TypeScript types describe expected shapes; Zod
checks untrusted runtime values.

## Prefer

```ts
import { z } from "zod";

const projectSchema = z.object({
  id: z.string(),
  name: z.string(),
});

export type Project = z.infer<typeof projectSchema>;

export async function getProject(id: string): Promise<Project> {
  const data = await apiJson<unknown>(`/api/projects/${id}`);
  return projectSchema.parse(data);
}
```

## Avoid

```ts
const project = (await response.json()) as Project;
```

## Notes

- Use `parse` when invalid data should fail fast.
- Use `safeParse` when the UI should recover or show a validation message.
- Keep schemas focused; avoid huge global schema files that become dumping
  grounds.
- Reuse the same schema for form values and API input only when the contract is
  truly identical.
