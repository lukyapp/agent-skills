# dto-validation

## Use When

- Creating DTOs for request bodies, query params, route params, or env config.
- Accepting external input at controller boundaries.
- Adding validation errors or request transformation.

## Rule

Validate inbound HTTP data with Nest DTOs and the global `ValidationPipe`.
Keep DTOs explicit and let controllers receive typed, transformed values.

## Prefer

```ts
export class CreateProjectDto {
  @IsString()
  @IsNotEmpty()
  name!: string;
}
```

```ts
@Post()
create(@Body() input: CreateProjectDto) {
  return this.projectsService.create(input);
}
```

## Avoid

```ts
@Post()
create(@Body() body: any) {
  return this.projectsService.create(body);
}
```

## Notes

- The global pipe should use `whitelist`, `forbidNonWhitelisted`, and
  `transform`.
- Use `class-validator` and `class-transformer` when following this boilerplate.
- Validate data again at non-HTTP trust boundaries when needed, such as webhook
  payloads, job payloads, or third-party responses.
