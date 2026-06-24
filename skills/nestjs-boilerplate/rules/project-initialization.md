# project-initialization

## Use When

- Creating a new NestJS API from scratch.
- Initializing a backend project before applying this boilerplate.
- Replacing a hand-written NestJS starter scaffold.

## Rule

Use the official Nest CLI to scaffold new NestJS projects, then apply boilerplate
conventions. Do not manually create the initial NestJS project structure when
the official CLI can do it.

Use `--strict` for new TypeScript projects unless the user or target repository
requires a looser configuration.

## Prefer

```bash
npm i -g @nestjs/cli
nest new project-name --strict
```

## Avoid

```bash
mkdir project-name
touch package.json nest-cli.json src/main.ts src/app.module.ts
```

## Notes

- Prefer the package manager already used by the workspace when the Nest CLI
  asks which package manager to use.
- After scaffolding, apply this boilerplate's Prisma, env validation, auth,
  permissions, Swagger, security, and testing rules.
- If the official Nest initializer changes, follow the current official NestJS
  docs over the examples in this rule.
