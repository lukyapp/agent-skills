# typescript-tooling

## Use When

- Editing TypeScript config, lint config, package scripts, generated clients, or
  imports.
- Adding new scripts for build, format, lint, Prisma, or tests.
- Reviewing type safety.

## Rule

Keep backend TypeScript strict and generated code isolated. Use Prettier,
type-aware ESLint, and pnpm scripts matching the boilerplate.

## Prefer

```json
{
  "scripts": {
    "prebuild": "pnpm prisma:generate",
    "build": "nest build",
    "format:check": "prettier --check \"src/**/*.ts\" \"test/**/*.ts\"",
    "lint": "eslint \"{src,test}/**/*.ts\" --fix",
    "test:e2e": "jest --config test/jest-e2e.json"
  }
}
```

## Avoid

```ts
// eslint-disable-next-line
const value: any = payload;
```

## Notes

- Use `module` and `moduleResolution` set to `nodenext`.
- Keep `strict`, `noImplicitAny`, and decorator metadata enabled.
- Ignore `src/generated/**` in ESLint.
- Treat `@typescript-eslint/no-floating-promises` and
  `@typescript-eslint/no-unsafe-argument` as warnings unless the repo chooses a
  stricter profile.
