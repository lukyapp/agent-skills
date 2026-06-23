# Rule Sections

| Prefix | Section | Purpose |
| --- | --- | --- |
| `api-` | API Client | Centralize request, response, auth, and error handling. |
| `async-ui-` | Async UI States | Represent loading, empty, error, and success states. |
| `client-state-` | Client State | Manage local-only app state without replacing server state tools. |
| `dates-` | Dates | Parse, format, and calculate dates with one approved library. |
| `domain-` | Domain Structure | Organize React app code by business domain with hexagonal boundaries. |
| `env-vars-` | Environment Variables | Validate and expose configuration safely. |
| `forms-` | Forms | Build typed, validated, maintainable form flows. |
| `i18n-` | Internationalization | Use repository translation systems instead of inline copy. |
| `library-` | Library Selection | Decide which project dependency or local abstraction to use. |
| `notifications-` | Notifications | Show transient mutation and background-task feedback consistently. |
| `react-query-` | API Calls and Server State | Fetch, cache, mutate, invalidate, and represent remote data. |
| `routing-` | Routing | Use typed routing conventions for app navigation. |
| `testing-` | Testing | Choose unit, component, mock API, and browser tests. |
| `ui-` | UI Conventions | Use project UI, styling, icon, date, and toast conventions. |
| `url-state-` | URL State | Store shareable view state in typed URL search params. |
| `validation-` | Validation | Validate external data at trust boundaries. |

Add new sections only when several rules share the same concern.
