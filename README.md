# swift-authentication

Who is calling, proved by a credential, and carried with the call.

```swift
.package(url: "https://github.com/swift-microservices/swift-authentication.git", from: "0.2.0"),
```

```swift
.product(name: "Authentication", package: "swift-authentication"),
```

## The shape

A caller proves who they are with a credential: a bearer token, a certificate. Every credential
follows one path, and this package is that path with the credential left generic:

| Type | Role |
| --- | --- |
| `Authenticator<Credential, Identity>` | turns a credential into the identity it proves, declines with `nil`, or refuses by throwing |
| `CredentialIssuer<Identity, Credential>` | mints the credential that proves an identity; one process holds the private key |
| `Principal<Identity, Credential>` | the party a credential proved: the identity, and the credential itself |
| `PrincipalKey<Identity, Credential>` | the `ServiceContext` key a transport binds the principal under for the length of a call |

It depends on nothing but swift-service-context and knows no credential. Whether an identity is a
person or a process is a claim inside it; the package never reads the claims.

## The family

| Package | Adds | Depends on |
| --- | --- | --- |
| swift-authentication-jwt | `JWTAuthenticator`, `JWTIssuer`: a bearer token as a JSON Web Token | jwt-kit |
| swift-authentication-x509 | `SPIFFEAuthenticator`, `SPIFFEID`: a certificate by its SPIFFE name | swift-certificates |
| swift-authentication-grpc | interceptors that read a bearer token or the peer certificate, bind the principal, and present the token onward | grpc-swift-2 |
| swift-authentication-hummingbird | the bearer middleware for Hummingbird | hummingbird-auth |
| swift-authentication-vapor | the bearer middleware for Vapor | vapor |

A proof package knows how to check a credential. A transport package knows where to find one and
where to bind the result. Neither knows about the other.

## Three answers

An authenticator answers one of three ways. An identity binds a principal. `nil` declines: the
credential names nobody this service recognises, and the call continues unbound. A throw refuses:
the credential does not verify, and the call fails as unauthenticated. A call with no credential
never reaches the authenticator and continues anonymously; requiring a caller is the handler's
decision.

## Reading the caller

`ServiceContext` is the one task-local the server ecosystem shares: tracing puts spans in it, a
`Logger.MetadataProvider` reads it for every log line, and the transports carry it. Binding the
principal there means the caller can appear in every log line of a request without the app
wiring anything. An app usually spells the lookup once:

```swift
extension ServiceContext {
    var caller: Principal<AppToken, String>? {
        self[PrincipalKey<AppToken, String>.self]
    }
}
```

```swift
guard let caller = ServiceContext.current?.caller?.identity else {
    throw RPCError(code: .unauthenticated, message: "Sign in to continue.")
}
```

A use-case test that needs a bound caller uses the standard API:

```swift
var context = ServiceContext.topLevel
context[PrincipalKey<AppToken, String>.self] = Principal(identity: token, credential: "-")
try await ServiceContext.withValue(context) { try await useCase(input: input) }
```

## Requirements

Swift 6.3, macOS 15 or Linux.

## Development

```sh
swift test
swift-format lint --strict --recursive Sources Tests    # what the soundness check runs
```

## Contributing

Pull requests are welcome. Keep a change focused, prove new behaviour with a test, and label the
pull request with its semantic version impact.

## License

MIT. See [LICENSE](LICENSE).
