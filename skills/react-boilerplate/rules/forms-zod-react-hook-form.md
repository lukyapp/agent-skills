# forms-zod-react-hook-form

## Use When

- Creating or refactoring a form.
- Validating form input.
- Mapping server field errors back into the UI.

## Rule

Use React Hook Form for non-trivial form state and Zod for validation. Avoid
large `useState` objects for form fields.

## Prefer

```tsx
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

const projectSchema = z.object({
  name: z.string().min(1, "Name is required"),
});

type ProjectFormValues = z.infer<typeof projectSchema>;

export function ProjectForm() {
  const form = useForm<ProjectFormValues>({
    resolver: zodResolver(projectSchema),
    defaultValues: {
      name: "",
    },
  });

  return (
    <form onSubmit={form.handleSubmit((values) => console.log(values))}>
      <input {...form.register("name")} />
      {form.formState.errors.name ? (
        <p>{form.formState.errors.name.message}</p>
      ) : null}
      <button type="submit">Save</button>
    </form>
  );
}
```

## Avoid

```tsx
const [name, setName] = useState("");
const [nameError, setNameError] = useState("");
```

## Notes

- Use the repository's form components when they exist.
- Keep schemas near the feature unless they are shared by API contracts.
- Prefer `defaultValues` over uncontrolled shape drift.
- Use server errors through `setError` when the API returns field-specific
  validation failures.
