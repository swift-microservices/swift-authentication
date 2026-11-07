# Swift Authentication

[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/swift-microservices/swift-authentication/documentation)
[![Release](https://img.shields.io/github/v/release/swift-microservices/swift-authentication)](https://github.com/swift-microservices/swift-authentication/releases)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-microservices%2Fswift-authentication%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-microservices/swift-authentication)
[![CI](https://github.com/swift-microservices/swift-authentication/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/swift-microservices/swift-authentication/actions/workflows/ci.yml)

Swift Authentication answers one question for a server: who is calling? It defines how a presented
credential is proved into an identity, and how that identity travels with the call to the code
that needs it, without tying you to a token format or a web framework.

- 🚀 Four small types: `Authenticator`, `CredentialIssuer`, `Principal` and `PrincipalKey`
- 📦 One dependency: [swift-operation-context](https://github.com/swift-microservices/swift-operation-context)
- 🐧 Supports Linux (including the static SDK) and macOS 15+
- 🔧 Built with Swift 6.3, in the Swift 6 language mode

🔗 Jump to:
- 📖 [Overview](#-overview)
- 🏁 [Getting Started](#-getting-started)
- 📘 [Documentation](#-documentation)
- 🧰 [Release Info](#-release-info)
- 🛠️ [Support](#%EF%B8%8F-support)

## 📖 Overview

An authenticator proves a presented credential and returns its identity. A transport (an HTTP
middleware or a gRPC interceptor) reads the credential off the request, runs the authenticator,
and binds the result as a principal in the task's `OperationContext` for the length of the call.
Your handlers and use cases read the principal from there instead of threading the caller through
every signature.

This package defines that contract with the credential and identity left generic. It knows no
concrete credential or claims; companion packages add a JWT proof and the transport bindings.

| Type | Role |
| --- | --- |
| `Authenticator<Credential, Identity>` | turns a presented credential into the identity it proves, or throws if authentication fails |
| `CredentialIssuer<Identity, Credential>` | mints the credential that proves an identity; one process holds the private key |
| `Principal<Identity, Credential>` | the party a credential proved: the identity, and the credential itself |
| `PrincipalKey<Identity, Credential>` | the `OperationContext` key a transport binds the principal under for the length of a call |

**Key Features:**
- 🧩 **Generic over credential and identity**: a bearer string, an API key or a certificate on one
  side; your own token payload or account type on the other
- 🔐 **Issue and authenticate as a pair**: one process holds the private key and issues, every
  other holds the public key and authenticates, and transports never learn which format is in use
- 🔁 **Forwardable**: a `Principal` keeps the credential as presented, so a service relaying the
  call can present the same one to the next service
- 🧵 **Task-scoped**: the principal is bound for one call, structured child tasks inherit it, and
  the enclosing binding is restored when the call ends
- 🔌 **Transport-independent**: a proof package knows how to check a credential, a transport
  package knows where to find one and where to bind the result, and neither knows about the other

### The contract

An authenticator returns an identity or throws. A successful return establishes the identity a
transport binds as a principal. A failed authentication throws, and the supplied transports
translate that into their unauthenticated response (`401 Unauthorized`, or gRPC
`unauthenticated`).

A call with no credential never reaches the authenticator and continues anonymously, so looking
up a principal always returns an optional. Requiring a caller is the handler's or use case's
decision, and so is deciding what an authenticated identity may do.

### Security model

mTLS secures service-to-service connections. User JWTs authenticate the user making a request;
each receiving service verifies the original token, and the owning use case checks permissions.
User principals and database settings are scoped to user operations. Internal operations accept
business input and enforce domain invariants.

### The family

| Package | Adds |
| --- | --- |
| [swift-authentication-jwt](https://github.com/swift-microservices/swift-authentication-jwt) | `JWTAuthenticator` and `JWTIssuer`: a bearer token as a JSON Web Token, on jwt-kit |
| [swift-authentication-vapor](https://github.com/swift-microservices/swift-authentication-vapor) | `BearerAuthenticationMiddleware`: proves a Vapor request's bearer token and binds the principal |
| [swift-authentication-hummingbird](https://github.com/swift-microservices/swift-authentication-hummingbird) | `BearerAuthenticationMiddleware`: the same for Hummingbird, on hummingbird-auth |
| [swift-authentication-grpc](https://github.com/swift-microservices/swift-authentication-grpc) | `BearerAuthenticationInterceptor` and `BearerPropagationInterceptor`: authenticate user RPCs and forward the token, on grpc-swift-2 |

On the client side, [swift-token-authentication](https://github.com/swift-microservices/swift-token-authentication)
signs in, refreshes, and presents the bearer token for apps and SDKs calling a Swift API, with a
middleware for generated OpenAPI clients. It does not depend on this package.

## 🏁 Getting Started

### Prerequisites

- Swift version: Swift 6.3+
- Platforms: macOS 15+ or Linux

To install/upgrade Swift, see https://www.swift.org/install/

### Adding as a dependency

Add the package to your `Package.swift`. Add `OperationContext` too if your code reads the bound
principal:

```swift
dependencies: [
    .package(url: "https://github.com/swift-microservices/swift-authentication.git", from: "1.0.0"),
    .package(url: "https://github.com/swift-microservices/swift-operation-context.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyService",
        dependencies: [
            .product(name: "Authentication", package: "swift-authentication"),
            .product(name: "OperationContext", package: "swift-operation-context"),
        ]
    ),
]
```

### Usage

#### Implementing an authenticator

An authenticator knows one credential kind. This one accepts API keys and returns the account
each key belongs to. For bearer JWTs, use `JWTAuthenticator` from swift-authentication-jwt
instead of writing your own.

```swift
import Authentication

// Your identity type: whatever your handlers need to know about the caller.
struct Account: Sendable {
    let id: String
    let isAdmin: Bool
}

struct APIKeyAuthenticator: Authenticator {
    struct UnknownKey: Error {}

    let accounts: [String: Account]  // API key -> account

    // Return the identity the credential proves, or throw if it proves nothing.
    func authenticate(_ credential: String) async throws -> Account {
        guard let account = accounts[credential] else { throw UnknownKey() }
        return account
    }
}
```

Hand it to a transport, for example swift-authentication-grpc's
`BearerAuthenticationInterceptor(authenticator: APIKeyAuthenticator(accounts: ...))`, and every
call that presents a key runs with a `Principal<Account, String>` bound. (The Vapor and
Hummingbird middleware additionally require the identity to fit their framework's auth types.)

#### Reading the caller inside a use case

Spell the lookup once, then read it wherever the caller matters. The use case below requires a
signed-in caller and lets only the author or an administrator delete a post:

```swift
import Authentication
import OperationContext

extension OperationContext {
    var caller: Principal<Account, String>? {
        self[PrincipalKey<Account, String>.self]
    }
}

// Your own persistence port.
protocol PostStore: Sendable {
    func authorID(ofPost postID: String) async throws -> String
    func deletePost(_ postID: String) async throws
}

struct DeletePost: Sendable {
    enum Failure: Error { case unauthenticated, forbidden }

    let posts: any PostStore

    func callAsFunction(postID: String) async throws {
        // No credential means no principal: requiring one is this use case's decision.
        guard let caller = OperationContext.current.caller?.identity else {
            throw Failure.unauthenticated
        }
        // Authorization is the application's decision, made after authentication.
        let authorID = try await posts.authorID(ofPost: postID)
        guard caller.id == authorID || caller.isAdmin else { throw Failure.forbidden }

        try await posts.deletePost(postID)
    }
}
```

Transports bind the principal around the rest of the request. Structured child tasks inherit it,
and the previous context is restored when the scope exits. `PrincipalKey` is generic over both
types, so bindings with different identity or credential types never collide.

#### Testing with a bound caller

A test binds a principal itself with the standard `OperationContext` API, no transport needed:

```swift
import Authentication
import OperationContext
import Testing

@Test func authorCanDeleteTheirPost() async throws {
    let deletePost = DeletePost(posts: InMemoryPostStore(authorID: "alice"))  // your test double

    var context = OperationContext()
    context[PrincipalKey<Account, String>.self] = Principal(
        identity: Account(id: "alice", isAdmin: false),
        credential: "test-key"
    )

    try await OperationContext.withContext(context) {
        try await deletePost(postID: "post-1")
    }
}
```

`withContext(_:operation:)` replaces the whole binding for the scope. Copy
`OperationContext.current` first if the test already binds other values.

## 📘 Documentation

- [API Documentation](https://swiftpackageindex.com/swift-microservices/swift-authentication/documentation)
  - the full reference on Swift Package Index
- [Principals and credentials](https://swiftpackageindex.com/swift-microservices/swift-authentication/documentation/authentication/principalsandcredentials)
  - how a verified identity and its original credential travel through a request, the security
  boundaries between user and internal operations, and how context scope is restored
- [swift-operation-context](https://github.com/swift-microservices/swift-operation-context)
  - the task-local container the principal is bound in

## 🧰 Release Info

- Versioning: [Semantic Versioning](https://semver.org). The public API is stable from 1.0.0 and
  only a major release breaks it; CI checks every pull request for API breakage.
- Release notes: [GitHub Releases](https://github.com/swift-microservices/swift-authentication/releases)
- Swift versions: CI tests Swift 6.3 and 6.4 on Linux (x86_64 and aarch64, plus the static SDK),
  and nightly toolchains.
- Dependencies: swift-operation-context 1.0.

## 🛠️ Support

If you have a question or found a bug, [open an issue](https://github.com/swift-microservices/swift-authentication/issues).

Pull requests are welcome. Keep a change focused, prove new behaviour with a test, and label the
pull request with its semantic version impact.

### Development

```sh
swift test
swift-format lint --strict --recursive Sources Tests    # what the soundness check runs
```

## License

MIT. See [LICENSE](LICENSE).
