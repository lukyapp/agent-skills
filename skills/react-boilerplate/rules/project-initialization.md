# project-initialization

## Use When

- Creating a new React app from scratch.
- Initializing a Vite React TypeScript project.
- Replacing a hand-written starter scaffold.

## Rule

Use the official scaffolding command for the framework, then apply boilerplate
conventions. Do not manually create a new React/Vite project structure from
scratch when an official initializer exists.

For Vite React TypeScript, use the official `create-vite` flow with the
`react-ts` template.

## Prefer

```bash
pnpm create vite my-app --template react-ts
```

```bash
npm create vite@latest my-app -- --template react-ts
```

## Avoid

```bash
mkdir my-app
touch package.json index.html src/main.tsx src/App.tsx
```

## Notes

- Prefer the package manager already used by the workspace.
- Use `.` as the project name only when the user explicitly wants to scaffold in
  the current directory.
- After scaffolding, install approved boilerplate libraries and apply local
  rules for routing, API calls, state, forms, validation, styling, and tests.
- If the official initializer changes, follow the current official Vite docs
  over the examples in this rule.
