# Rule Sections

| Prefix | Section | Purpose |
| --- | --- | --- |
| `app-` | App Bootstrap | Configure platform-wide security, validation, CORS, Swagger, and listen behavior. |
| `decorators-` | Decorators | Keep auth, permissions, and Swagger route metadata reusable. |
| `dto-` | DTO Validation | Validate inbound request data through Nest DTOs and global pipes. |
| `env-` | Environment Validation | Fail startup when required configuration is missing or malformed. |
| `error-` | Error Contract | Return predictable HTTP error responses. |
| `helpers-` | Helpers | Centralize small reusable date and user helpers without over-abstracting. |
| `library-` | Library Selection | Choose approved backend dependencies and local abstractions. |
| `module-` | Module Structure | Organize API code by Nest modules and business domains. |
| `oidc-` | OIDC JWT Auth | Validate bearer tokens through OIDC discovery and JWKS. |
| `permissions-` | Permissions | Authorize routes with relation-style permission requirements. |
| `prisma-` | Prisma Postgres | Use Prisma 7 with the PostgreSQL adapter and lifecycle hooks. |
| `project-` | Project Initialization | Scaffold new NestJS apps with official CLI commands before applying conventions. |
| `security-` | Security and Throttling | Apply default HTTP hardening and rate limits. |
| `swagger-` | Swagger OpenAPI | Generate protected API docs with bearer auth metadata. |
| `testing-` | Testing | Cover services, guards, and HTTP behavior with focused tests. |
| `tooling-` | TypeScript Tooling | Keep strict TypeScript, ESLint, Prettier, and generated code conventions. |

Add new sections only when several rules share the same concern.
