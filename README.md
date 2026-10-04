# swift-authentication

[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/swift-microservices/swift-authentication/documentation)

Who is calling, proved by a credential, and carried with the call.

```swift
.package(url: "https://github.com/swift-microservices/swift-authentication.git", from: "0.3.0"),
```

```swift
.product(name: "Authentication", package: "swift-authentication"),
```

## The shape

An authenticator proves a presented credential and returns its identity. This package defines
that contract with the credential and identity left generic:

| Type | Role |
| --- | --- |
| `Authenticator<Credential, Identity>` | turns a presented credential into the identity it proves, or throws if authentication fails |
| `CredentialIssuer<Identity, Credential>` | mints the credential that proves an identity; one process holds the private key |
| `Principal<Identity, Credential>` | the party a credential proved: the identity, and the credential itself |
| `PrincipalKey<Identity, Credential>` | the `ServiceContext` key a transport binds the principal under for the length of a call |

It depends only on swift-service-context and knows no concrete credential or claims.

## The family

| Package | Adds | Depends on |
| --- | --- | --- |
| swift-authentication-jwt | `JWTAuthenticator`, `JWTIssuer`: a bearer token as a JSON Web Token | jwt-kit |
| swift-authentication-grpc | user bearer authentication and propagation on user RPC descriptors | grpc-swift-2 |
| swift-authentication-hummingbird | the bearer middleware for Hummingbird | hummingbird-auth |
| swift-authentication-vapor | the bearer middleware for Vapor | vapor |

A proof package knows how to check a credential. A transport package knows where to find one and
where to bind the result. Neither knows about the other.

On the client side, [swift-openapi-token-authentication](https://github.com/swift-microservices/swift-openapi-token-authentication)
signs in, refreshes, and presents the bearer token for apps and SDKs calling a Swift OpenAPI
surface. It does not depend on this package.

## Authenticating a credential

An authenticator returns an identity or throws. A successful return establishes the identity a
transport binds as a principal. A failed authentication throws. The supplied transports
translate authentication failures into their unauthenticated response.

A call with no credential never reaches the authenticator and continues anonymously; requiring
a caller is the handler's decision. Looking up a principal in `ServiceContext` remains optional
because a call may carry no credential. Permission to perform an operation is the application's
decision after authentication.

## Security model

mTLS secures service-to-service connections. User JWTs authenticate the user making a request;
each receiving service verifies the original token, and the owning use case checks permissions.
User principals and database settings are scoped to user operations. Internal operations accept
business input and enforce domain invariants.

## Reading the user

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

Swift 6.3, macOS 15 or Linux. swift-service-context 1.3.

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
