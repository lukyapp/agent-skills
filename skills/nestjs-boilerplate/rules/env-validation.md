# env-validation

## Use When

- Adding or changing environment variables.
- Reading configuration at startup or inside services.
- Creating `env.example`.

## Rule

Validate environment variables at startup through `ConfigModule.forRoot` and a
typed validation function. Required variables must fail startup with a readable
error.

## Prefer

```ts
ConfigModule.forRoot({
  isGlobal: true,
  validate: validateEnv,
});
```

```ts
class EnvVariables {
  @IsString()
  @IsNotEmpty()
  DATABASE_URL!: string;
}
```

## Avoid

```ts
const databaseUrl = process.env.DATABASE_URL!;
```

## Notes

- Keep `DATABASE_URL`, `ACCEPTED_ISSUERS`, and `ACCEPTED_ALGORITHMS` required.
- Trim comma-separated auth config before use.
- Document every variable in `env.example` with required/optional status and
  default behavior.
- It is acceptable for low-level services such as `PrismaService` to re-check
  critical env vars before connecting.
