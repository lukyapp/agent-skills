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
