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
| `responsive-` | Responsive UI | Build mobile-first layouts, controls, and content flows. |
| `routing-` | Routing | Use typed routing conventions for app navigation. |
| `tables-` | Tables and Lists | Build filterable, sortable, paginated collection views. |
| `testing-` | Testing | Choose unit, component, mock API, and browser tests. |
| `theme-` | Theme Colors | Centralize light and dark color tokens instead of hard-coded palette classes. |
| `ui-` | UI Conventions | Use project UI, styling, icon, date, and toast conventions. |
| `url-state-` | URL State | Store shareable view state in typed URL search params. |
| `validation-` | Validation | Validate external data at trust boundaries. |

Add new sections only when several rules share the same concern.
