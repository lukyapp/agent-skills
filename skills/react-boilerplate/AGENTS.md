# Luky App React Boilerplate

This file is generated from `rules/*.md`.

Use these rules when creating, modifying, or reviewing React, Next.js, or
TypeScript frontend code in projects that should follow Luky app boilerplate
conventions.

Prefer the target repository's existing code first, then these rules when the
repository has no clear precedent.

## Workflow

1. Inspect `package.json` and nearby implementation patterns before editing.
2. Use installed dependencies and local helpers.
3. Keep code typed, direct, and maintainable.
4. Add a new rule when a preference becomes recurring.

# Rule Sections

| Prefix | Section | Purpose |
| --- | --- | --- |
| `accessibility-` | Accessibility | Keep forms, controls, focus, and keyboard behavior usable. |
| `analytics-` | Analytics Events | Track typed product events through adapters without platform lock-in. |
| `api-error-` | API Error Contract | Standardize API error responses and UI mapping. |
| `api-` | API Client | Centralize request, response, auth, and error handling. |
| `async-ui-` | Async UI States | Represent loading, empty, error, and success states. |
| `cache-` | Cache Invalidation | Keep React Query keys and invalidations predictable. |
| `client-state-` | Client State | Manage local-only app state without replacing server state tools. |
| `dates-` | Dates | Parse, format, and calculate dates with one approved library. |
| `domain-` | Domain Structure | Organize React app code by business domain with hexagonal boundaries. |
| `env-vars-` | Environment Variables | Validate and expose configuration safely. |
| `forms-` | Forms | Build typed, validated, maintainable form flows. |
| `i18n-` | Internationalization | Use repository translation systems instead of inline copy. |
| `library-` | Library Selection | Decide which project dependency or local abstraction to use. |
| `modals-` | Modals and Confirmations | Use accessible dialogs and safe destructive flows. |
| `notifications-` | Notifications | Show transient mutation and background-task feedback consistently. |
| `optimistic-` | Optimistic Updates | Update React Query cache optimistically with rollback. |
| `react-query-` | API Calls and Server State | Fetch, cache, mutate, invalidate, and represent remote data. |
| `routing-` | Routing | Use typed routing conventions for app navigation. |
| `tables-` | Tables and Lists | Build filterable, sortable, paginated collection views. |
| `testing-` | Testing | Choose unit, component, mock API, and browser tests. |
| `ui-` | UI Conventions | Use project UI, styling, icon, date, and toast conventions. |
| `url-state-` | URL State | Store shareable view state in typed URL search params. |
| `validation-` | Validation | Validate external data at trust boundaries. |

Add new sections only when several rules share the same concern.

# accessibility

## Use When

- Creating forms, buttons, links, dialogs, menus, tabs, tables, icon buttons, or
  custom interactive components.
- Adding validation errors, loading states, keyboard shortcuts, or focus
  management.
- Replacing semantic HTML with custom markup.

## Rule

Prefer semantic HTML and accessible design-system primitives. Every interactive
control must have an accessible name, keyboard behavior, visible focus, and
clear disabled or pending state.

## Prefer

```tsx
export function DeleteProjectButton() {
  const deleteProject = useDeleteProject();

  return (
    <button
      type="button"
      aria-label="Delete project"
      disabled={deleteProject.isPending}
      onClick={() => deleteProject.mutate()}
    >
      <Trash aria-hidden="true" />
    </button>
  );
}
```

```tsx
<label htmlFor="project-name">Name</label>
<input
  id="project-name"
  aria-invalid={Boolean(error)}
  aria-describedby={error ? "project-name-error" : undefined}
/>
{error ? <p id="project-name-error">{error.message}</p> : null}
```

## Avoid

```tsx
<div onClick={onSave}>Save</div>
<button><Trash /></button>
```

## Notes

- Use `button` for actions and links for navigation.
- Provide `aria-label` for icon-only buttons.
- Mark decorative icons with `aria-hidden="true"`.
- Keep focus trapped in dialogs and return focus after close when the design
  system does not handle it.
- Do not remove focus outlines without replacing them with a visible focus
  style.
- Associate form errors with fields using `aria-describedby`.
- Prefer accessible component primitives for dialogs, menus, popovers, tabs,
  and selects.

# analytics-events

## Use When

- Tracking product events such as create, delete, invite, upload, checkout,
  search, filter, export, onboarding, or settings changes.
- Adding analytics without choosing a hosted analytics platform yet.
- Refactoring direct SDK calls, scattered `console.log`, or click-level event
  names.

## Rule

Use platformless typed analytics. Define analytics as an application port with
adapters. Start with a console logger adapter; add platform adapters later only
when the product needs them.

Do not import analytics SDKs directly inside components, domain code, or
feature flows.

## Preferred Shape

```text
src/
  shared/
    analytics/
      analytics-events.ts
      analytics-port.ts
      console-analytics-adapter.ts
      track-event.ts
```

## Prefer

```ts
export type AnalyticsEvent =
  | {
      name: "project_created";
      properties: {
        projectId: string;
        source: "header_button" | "empty_state";
      };
    }
  | {
      name: "file_uploaded";
      properties: {
        fileType: string;
        fileSizeMb: number;
      };
    };
```

```ts
export type AnalyticsAdapter = {
  track: (event: AnalyticsEvent) => void | Promise<void>;
};
```

```ts
export const consoleAnalyticsAdapter: AnalyticsAdapter = {
  track: (event) => {
    if (process.env.NODE_ENV !== "production") {
      console.info("[analytics]", event);
    }
  },
};
```

```ts
let analyticsAdapter: AnalyticsAdapter = consoleAnalyticsAdapter;

export function configureAnalytics(adapter: AnalyticsAdapter) {
  analyticsAdapter = adapter;
}

export function trackEvent(event: AnalyticsEvent) {
  return analyticsAdapter.track(event);
}
```

Use analytics after successful business events:

```ts
export function useCreateProject() {
  return useMutation({
    mutationFn: createProject,
    onSuccess: (project) => {
      trackEvent({
        name: "project_created",
        properties: {
          projectId: project.id,
          source: "header_button",
        },
      });
    },
  });
}
```

## Avoid

```ts
console.log("clicked create project");
```

```ts
posthog.capture("click", { email: user.email });
```

```tsx
<Button onClick={() => trackEvent({ name: "clicked_button" })}>
  Create project
</Button>
```

## Notes

- Track business events after success, not raw clicks before the operation
  succeeds.
- Use stable event names in snake_case, such as `project_created`.
- Keep event properties typed and intentionally small.
- Never send passwords, tokens, emails, names, private content, or other PII
  unless the product has explicit privacy requirements and consent.
- Keep analytics calls out of pure domain code.
- Add adapters such as `posthogAnalyticsAdapter`, `segmentAnalyticsAdapter`, or
  `internalApiAnalyticsAdapter` later behind the same port if needed.
- The console adapter is the default starting point and should be quiet in
  production unless explicitly configured otherwise.

# api-client

## Use When

- Adding a new API call.
- Repeating `fetch` options, headers, base URLs, response parsing, or error
  handling.
- Wiring authenticated client requests.

## Rule

Prefer the repository's shared API client. If none exists, create the smallest
typed wrapper before adding more raw `fetch` calls.

The API client should centralize:

- base URL or relative API prefix
- JSON request and response parsing
- auth/session headers when the app uses them
- standard API errors
- request cancellation via `AbortSignal` when useful

## Prefer

```ts
export class ApiError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

export async function apiJson<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(path, {
    ...init,
    headers: {
      "content-type": "application/json",
      ...init?.headers,
    },
  });

  if (!response.ok) {
    throw new ApiError("API request failed", response.status);
  }

  return response.json() as Promise<T>;
}
```

## Avoid

```ts
const response = await fetch("/api/projects");
const projects = await response.json();
```

## Notes

- Do not create a second API abstraction if the repo already has one.
- Keep API functions outside React components.
- Validate untrusted response bodies with Zod when correctness matters.

# api-error-contract

## Use When

- Creating or consuming API routes, server actions, or client API wrappers.
- Mapping API failures to forms, toasts, inline errors, or error boundaries.
- Replacing inconsistent error shapes such as strings, HTML, or arbitrary JSON.

## Rule

Use a stable API error contract. Client code should be able to distinguish
global errors from field errors and authorization errors without parsing message
strings.

## Preferred Shape

```ts
export type ApiErrorCode =
  | "BAD_REQUEST"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "NOT_FOUND"
  | "VALIDATION_ERROR"
  | "CONFLICT"
  | "INTERNAL_ERROR";

export type ApiErrorBody = {
  error: {
    code: ApiErrorCode;
    message: string;
    fieldErrors?: Record<string, string[]>;
  };
};
```

## Prefer

```ts
export function validationError(
  fieldErrors: Record<string, string[]>,
): Response {
  return Response.json(
    {
      error: {
        code: "VALIDATION_ERROR",
        message: "Please check the highlighted fields.",
        fieldErrors,
      },
    } satisfies ApiErrorBody,
    { status: 422 },
  );
}
```

```ts
if (error instanceof ApiError && error.code === "VALIDATION_ERROR") {
  applyFieldErrors(form, error.fieldErrors);
  return;
}

toast.error(getApiErrorMessage(error));
```

## Avoid

```ts
return Response.json({ message: "nope" }, { status: 400 });
```

```ts
if (error.message.includes("validation")) {
  // ...
}
```

## Notes

- Use HTTP status for transport meaning and `error.code` for app meaning.
- Use `422` for validation errors when the backend supports it.
- Do not leak internal exception messages to users.
- Keep user-facing messages short and translatable in localized apps.
- Prefer field errors for form validation and toast/global errors for
  non-field failures.
- Update `api-client.md` behavior when introducing or changing the error class.

# async-ui-states

## Use When

- Rendering data loaded from an API.
- Building pages, panels, lists, tables, selects, dashboards, or detail views.
- Handling mutations that can be pending, failed, or successful.

## Rule

Every data-driven UI should represent loading, empty, error, and success states.
Use the repository's skeleton, spinner, alert, empty-state, and toast patterns
when they exist.

## Prefer

```tsx
export function ProjectList() {
  const projectsQuery = useProjects();

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  if (projectsQuery.data.length === 0) {
    return <EmptyState title="No projects yet" />;
  }

  return <ProjectsTable projects={projectsQuery.data} />;
}
```

## Avoid

```tsx
if (!projects) {
  return null;
}
```

## Notes

- Disable submit buttons or show pending state while mutations are running.
- Prefer local retry actions when a failed query can be retried.
- Use optimistic updates only when rollback behavior is clear.
- Do not hide errors silently.

# cache-invalidation

## Use When

- Adding React Query mutations.
- Designing query keys for lists, details, counts, dashboards, or search pages.
- Fixing stale UI after create, update, delete, upload, or reorder actions.

## Rule

Define stable query keys and invalidate the smallest useful cache scope after
mutations. Prefer feature-level query key helpers when a domain has more than
one query.

## Prefer

```ts
export const projectKeys = {
  all: ["projects"] as const,
  lists: () => [...projectKeys.all, "list"] as const,
  list: (params: ProjectListParams) => [...projectKeys.lists(), params] as const,
  detail: (projectId: string) => [...projectKeys.all, "detail", projectId] as const,
};
```

```ts
export function useUpdateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updateProject,
    onSuccess: (project) => {
      queryClient.setQueryData(projectKeys.detail(project.id), project);
      queryClient.invalidateQueries({ queryKey: projectKeys.lists() });
    },
  });
}
```

## Avoid

```ts
queryClient.invalidateQueries();
```

```ts
useQuery({ queryKey: ["data"], queryFn: listProjects });
```

## Notes

- Include every parameter that affects fetched data in the query key.
- Use list/detail key helpers for domains with multiple queries.
- After create: usually invalidate lists.
- After update: update detail cache and invalidate affected lists.
- After delete: remove or invalidate detail cache and invalidate affected lists.
- After upload: invalidate the entity detail and any asset/list queries that
  render the uploaded file.
- Use optimistic updates only when rollback behavior is clear.

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

# domain-feature-structure

## Use When

- Adding a new feature, route, hook, API integration, form, or state flow.
- Creating files for a business concept such as projects, users, billing,
  organizations, teams, subscriptions, reports, or settings.
- Refactoring code that mixes API calls, UI state, business rules, and rendering
  in the same component.

## Rule

Organize application code by business domain first. Keep a light hexagonal
architecture: domain code has no React dependency, application code expresses
use cases, infrastructure code talks to external systems, and UI code renders
and wires hooks.

## Preferred Shape

Use the repository's existing root folders. When no convention exists, prefer a
domain-first structure like this:

```text
src/
  domains/
    projects/
      domain/
        project.ts
        project-rules.ts
      application/
        project-queries.ts
        project-mutations.ts
        project-use-cases.ts
      infrastructure/
        project-api.ts
        project-schemas.ts
      ui/
        project-form.tsx
        project-list.tsx
        project-empty-state.tsx
      index.ts
```

For route-first frameworks such as Next.js App Router, keep route files thin and
delegate to domains:

```text
src/
  app/
    projects/
      page.tsx
      loading.tsx
      error.tsx
  domains/
    projects/
      ...
```

## Layer Responsibilities

`domain/`

- Put business types, entities, value objects, and pure rules here.
- Do not import React, TanStack Query, fetch clients, router APIs, or UI
  components.
- Keep code deterministic and easy to unit test.

`application/`

- Put use cases, query hooks, mutation hooks, orchestration, and app-specific
  workflows here.
- Use TanStack Query from this layer when creating React-facing hooks.
- Depend on `domain/` and `infrastructure/`, not on presentational UI.

`infrastructure/`

- Put API clients, Zod transport schemas, adapters, storage, analytics, and
  third-party SDK calls here.
- Convert external data into domain/application shapes.
- Keep raw HTTP details out of components.

`ui/`

- Put React components, forms, dialogs, tables, and view models here.
- Components may call application hooks.
- Keep business rules out of JSX when they can live in `domain/` or
  `application/`.

## Dependency Direction

Follow this direction:

```text
ui -> application -> domain
ui -> application -> infrastructure -> domain
```

Avoid these imports:

```text
domain -> ui
domain -> infrastructure
infrastructure -> ui
```

## Prefer

```tsx
// domains/projects/ui/project-list.tsx
export function ProjectList() {
  const projectsQuery = useProjects();

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  return <ProjectsTable projects={projectsQuery.data} />;
}
```

```ts
// domains/projects/application/project-queries.ts
export function useProjects() {
  return useQuery({
    queryKey: ["projects"],
    queryFn: listProjects,
  });
}
```

```ts
// domains/projects/infrastructure/project-api.ts
export async function listProjects() {
  const data = await apiJson<unknown>("/api/projects");
  return projectListSchema.parse(data);
}
```

## Avoid

```tsx
export function ProjectsPage() {
  const [projects, setProjects] = useState([]);

  useEffect(() => {
    fetch("/api/projects")
      .then((response) => response.json())
      .then((data) => {
        if (data.length > 10) {
          data.sort();
        }

        setProjects(data);
      });
  }, []);

  return <div>{JSON.stringify(projects)}</div>;
}
```

## Notes

- Do not over-split tiny features. Start with fewer files and create layers when
  the code has a real responsibility to isolate.
- Prefer domain names over technical names. Use `projects`, not `api` or
  `components`, as the main grouping.
- Shared generic UI remains in the app's design-system folders. Domain-specific
  UI stays in the domain.
- Cross-domain code should be explicit. If two domains need the same concept,
  extract a small shared kernel only after duplication is real.
- Keep barrel exports narrow. Do not export infrastructure internals from a
  public domain index unless another domain is meant to depend on them.

# env-vars-zod

## Use When

- Adding, reading, or refactoring environment variables.
- Splitting server-only and public client configuration.
- Replacing non-null assertions such as `process.env.API_KEY!`.

## Rule

Validate environment variables once with Zod in a central env module. Import
typed env values from that module instead of reading `process.env` throughout
the app.

## Prefer

```ts
import { z } from "zod";

const serverEnvSchema = z.object({
  DATABASE_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().min(1),
});

const clientEnvSchema = z.object({
  NEXT_PUBLIC_APP_URL: z.string().url(),
});

export const serverEnv = serverEnvSchema.parse(process.env);
export const clientEnv = clientEnvSchema.parse({
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
});
```

## Avoid

```ts
const stripeKey = process.env.STRIPE_SECRET_KEY!;
```

## Notes

- Never expose server secrets through `NEXT_PUBLIC_` variables.
- Keep client env exports limited to values safe for browsers.
- Use the framework's environment loading conventions.
- In tests, set env values explicitly before importing modules that parse env.

# file-uploads

## Use When

- Adding avatar, document, image, video, import, export, or attachment uploads.
- Handling file preview, progress, drag and drop, validation, or retry.
- Integrating an upload API, signed URL flow, or storage SDK.

## Rule

Treat uploads as mutations. Validate file type and size on the client for user
feedback, and require server-side validation for security. Keep selected files
out of global stores unless a multi-step flow needs them.

## Prefer

```tsx
const maxAvatarSize = 2 * 1024 * 1024;
const allowedAvatarTypes = new Set(["image/jpeg", "image/png", "image/webp"]);

function validateAvatar(file: File) {
  if (!allowedAvatarTypes.has(file.type)) {
    return "Use a JPG, PNG, or WebP image.";
  }

  if (file.size > maxAvatarSize) {
    return "Use an image smaller than 2 MB.";
  }

  return null;
}

export function AvatarUpload() {
  const uploadAvatar = useUploadAvatar();

  async function onFileChange(file: File | null) {
    if (!file) {
      return;
    }

    const error = validateAvatar(file);

    if (error) {
      toast.error(error);
      return;
    }

    uploadAvatar.mutate({ file });
  }

  return (
    <input
      aria-label="Upload avatar"
      type="file"
      accept="image/jpeg,image/png,image/webp"
      onChange={(event) => onFileChange(event.target.files?.[0] ?? null)}
    />
  );
}
```

## Avoid

```tsx
uploadAvatar.mutate({ file: event.target.files![0] });
```

## Notes

- Use `FormData` or a signed upload URL according to the existing backend
  pattern.
- Show progress when uploads can take noticeable time.
- Revoke preview object URLs when they are no longer needed.
- Disable submit controls while upload mutations are pending.
- Never rely on client-side file validation alone.
- Keep storage paths, ownership, virus scanning, and authorization on the server
  side.

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

# modals-and-confirmations

## Use When

- Adding dialogs, drawers, sheets, command menus, or confirmation prompts.
- Confirming destructive actions such as delete, revoke, archive, reset, or
  remove access.
- Placing forms inside modals or drawers.

## Rule

Use the repository's accessible dialog primitives. Destructive actions require a
clear confirmation step, pending state, and safe close behavior.

## Prefer

```tsx
export function DeleteProjectDialog({ projectId }: { projectId: string }) {
  const [open, setOpen] = useState(false);
  const deleteProject = useDeleteProject();

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button type="button" variant="destructive">
          Delete
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete project?</DialogTitle>
          <DialogDescription>
            This action cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            disabled={deleteProject.isPending}
            onClick={() => setOpen(false)}
          >
            Cancel
          </Button>
          <Button
            type="button"
            variant="destructive"
            disabled={deleteProject.isPending}
            onClick={() =>
              deleteProject.mutate(
                { projectId },
                { onSuccess: () => setOpen(false) },
              )
            }
          >
            Delete
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
```

## Avoid

```tsx
if (window.confirm("Delete?")) {
  deleteProject.mutate({ projectId });
}
```

## Notes

- Prefer design-system dialog components that handle focus trap and aria
  attributes.
- Keep destructive copy explicit about what will be deleted or changed.
- Disable close/cancel buttons only when closing would corrupt a critical
  in-flight flow; otherwise keep escape routes available.
- Close the modal after successful mutations, not before.
- Show form validation errors inside the dialog.
- Return focus to the trigger after close when the primitive does not handle it.

# notifications-sonner

## Use When

- Showing mutation success or failure.
- Reporting background task status.
- Replacing `alert`, inline-only transient feedback, or console-only errors.

## Rule

Use the repository's toast system for transient feedback. Prefer `sonner` when
it is installed and no stronger local wrapper exists.

## Prefer

```tsx
import { toast } from "sonner";

export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createProject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
      toast.success("Project created");
    },
    onError: () => {
      toast.error("Project could not be created");
    },
  });
}
```

## Avoid

```tsx
window.alert("Saved");
```

## Notes

- Do not toast every successful background refresh.
- Prefer field errors for form validation failures.
- Keep toast copy short and user-facing.
- Use the existing app toast wrapper when one exists, especially if it handles
  i18n, logging, or error normalization.

# optimistic-updates

## Use When

- A mutation changes data already shown in the UI.
- The UI should feel instant for low-risk actions such as toggles, renames,
  reordering, likes, or simple status changes.
- Refactoring mutation flows that wait for a full refetch before updating.

## Rule

Use TanStack Query optimistic updates only when rollback behavior is clear.
Prefer simple invalidation for complex writes, server-generated data, payments,
permissions, or workflows where a wrong temporary state would be confusing.

## Prefer

```ts
export function useRenameProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: renameProject,
    onMutate: async ({ projectId, name }) => {
      await queryClient.cancelQueries({ queryKey: ["projects"] });

      const previousProjects = queryClient.getQueryData<Project[]>([
        "projects",
      ]);

      queryClient.setQueryData<Project[]>(["projects"], (projects = []) =>
        projects.map((project) =>
          project.id === projectId ? { ...project, name } : project,
        ),
      );

      return { previousProjects };
    },
    onError: (_error, _variables, context) => {
      queryClient.setQueryData(["projects"], context?.previousProjects);
      toast.error("Project could not be renamed");
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
    },
  });
}
```

## Avoid

```ts
setProjects((projects) =>
  projects.map((project) =>
    project.id === projectId ? { ...project, name } : project,
  ),
);
```

## Notes

- Snapshot previous cache data in `onMutate`.
- Cancel affected queries before writing optimistic cache data.
- Roll back in `onError`.
- Invalidate or reconcile in `onSettled` or `onSuccess`.
- Keep optimistic cache updates scoped to the affected query keys.
- Do not duplicate server state into Zustand or component state for optimism.

# react-query-api-calls

## Use When

- Fetching data from the app API in React components or hooks.
- Creating mutations for create, update, delete, upload, or command actions.
- Handling loading, error, retry, cache, optimistic updates, or invalidation.
- Replacing ad hoc `useEffect` plus `fetch` server-state code.

## Rule

Use TanStack Query, commonly imported from `@tanstack/react-query`, for client
API calls and server state. Do not use component-local `useEffect` and
`useState` as the primary fetching mechanism for API data.

## Query Pattern

Create typed API functions outside components, then consume them through
`useQuery`.

```tsx
import { useQuery } from "@tanstack/react-query";

type Project = {
  id: string;
  name: string;
};

async function listProjects(): Promise<Project[]> {
  const response = await fetch("/api/projects");

  if (!response.ok) {
    throw new Error("Failed to load projects");
  }

  return response.json();
}

export function useProjects() {
  return useQuery({
    queryKey: ["projects"],
    queryFn: listProjects,
  });
}
```

## Mutation Pattern

Use `useMutation` for writes and invalidate or update affected queries after a
successful mutation.

```tsx
import { useMutation, useQueryClient } from "@tanstack/react-query";

type CreateProjectInput = {
  name: string;
};

async function createProject(input: CreateProjectInput) {
  const response = await fetch("/api/projects", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

  if (!response.ok) {
    throw new Error("Failed to create project");
  }

  return response.json();
}

export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createProject,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
    },
  });
}
```

## Avoid

```tsx
import { useEffect, useState } from "react";

export function Projects() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/projects")
      .then((response) => response.json())
      .then(setProjects)
      .finally(() => setLoading(false));
  }, []);

  return null;
}
```

## Notes

- Keep query keys stable, explicit, and colocated with the feature or query
  helper.
- Include all parameters that affect returned data in the query key.
- Use `enabled` for queries that depend on optional values.
- Prefer existing repository API clients over raw `fetch` when they exist.
- Surface errors through the app's existing toast, form, or error-boundary
  pattern instead of inventing a new display system.

# routing-tanstack-router

## Use When

- Working in a React/Vite app that uses `@tanstack/router` or
  `@tanstack/react-router`.
- Creating routes, links, navigation, route params, loaders, or search params
  outside a Next.js app.
- Refactoring stringly typed navigation in a TanStack Router project.

## Rule

Use TanStack Router's typed route APIs for React/Vite routing. Do not add React
Router or ad hoc route constants to a project that already uses TanStack Router.

## Prefer

```tsx
import { Link, createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/projects/$projectId")({
  component: ProjectPage,
});

function ProjectPage() {
  const { projectId } = Route.useParams();

  return (
    <Link to="/projects/$projectId/settings" params={{ projectId }}>
      Settings
    </Link>
  );
}
```

## Avoid

```tsx
window.location.href = `/projects/${projectId}/settings`;
```

## Notes

- In Next.js apps, use the repository's Next router conventions instead.
- Validate route search params with the router's search validation pattern,
  commonly with Zod when available.
- Include route params and search params in React Query keys when they affect
  fetched data.
- Keep navigation through `Link`, router hooks, or typed route helpers.

# tables-and-lists

## Use When

- Building collection views, tables, cards, grids, search results, or admin
  lists.
- Adding filters, sorting, pagination, row actions, selection, or bulk actions.
- Refactoring local-only list state that should be shareable or cached.

## Rule

Drive list data from URL state plus TanStack Query. Use TanStack Table when the
table needs sorting, column definitions, row selection, visibility, or complex
cell rendering. Keep simple lists simple.

## Prefer

```tsx
export function ProjectListPage() {
  const [page] = useQueryState("page", parseAsInteger.withDefault(1));
  const [search] = useQueryState("search", parseAsString.withDefault(""));

  const projectsQuery = useProjects({
    page,
    search,
  });

  if (projectsQuery.isPending) {
    return <ProjectListSkeleton />;
  }

  if (projectsQuery.isError) {
    return <ErrorState message="Projects could not be loaded." />;
  }

  if (projectsQuery.data.items.length === 0) {
    return <EmptyState title="No projects found" />;
  }

  return (
    <ProjectsTable
      projects={projectsQuery.data.items}
      pageCount={projectsQuery.data.pageCount}
    />
  );
}
```

```ts
export function useProjects(params: { page: number; search: string }) {
  return useQuery({
    queryKey: ["projects", params],
    queryFn: () => listProjects(params),
  });
}
```

## Avoid

```tsx
const [page, setPage] = useState(1);
const [projects, setProjects] = useState([]);
```

## Notes

- Put filters, sort, search, pagination, and view mode in URL state when users
  should be able to refresh, share, or navigate back to the same view.
- Include every list parameter that affects server data in the React Query key.
- Prefer server-side pagination/filtering for large or remote datasets.
- Keep destructive row actions behind confirmations.
- Preserve loading, empty, error, and success states.
- Use stable row IDs for table selection and optimistic updates.

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
