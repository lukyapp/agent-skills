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
