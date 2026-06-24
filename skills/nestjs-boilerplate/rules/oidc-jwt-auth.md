# oidc-jwt-auth

## Use When

- Adding authentication to routes.
- Validating bearer access tokens.
- Integrating an OIDC provider.
- Reading authenticated user profile claims.

## Rule

Use OIDC discovery and JWKS to validate JWT bearer tokens. Accept only configured
issuers, audiences, and algorithms. Sync basic OIDC profile fields to the local
database after successful validation.

## Prefer

```ts
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly authService: AuthService) {
    super({
      algorithms: authService.getAcceptedAlgorithms(),
      audience: authService.getAudiences(),
      issuer: authService.getAcceptedIssuers(),
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKeyProvider: (_request, rawToken, done) => {
        authService.getSigningKeyForToken(rawToken).then(
          (key) => done(null, key),
          (error) => done(error),
        );
      },
    });
  }
}
```

## Avoid

```ts
JwtModule.register({
  secret: process.env.JWT_SECRET,
});
```

## Notes

- Normalize issuers by removing trailing slashes before comparison.
- Cache OIDC discovery promises by issuer and JWKS clients by `jwks_uri`.
- Configure JWKS cache and rate limiting.
- Throw `UnauthorizedException` for missing issuer, unaccepted issuer, discovery
  mismatch, missing `jwks_uri`, invalid token, or signing-key resolution failure.
- Store local users by `oidcSubject`; update email, display name, image URL, and
  `lastSeenAt` on each authenticated request.
