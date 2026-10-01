# ``Authentication``

Who is calling, proved by a credential, and carried with the call.

## Overview

A caller proves who they are with a credential. This module is the shape of that, and nothing
more: an ``Authenticator`` turns a credential into the identity it proves, a ``CredentialIssuer``
mints one, and the result is a ``Principal``, the identity together with the credential, bound
under ``PrincipalKey`` in the task's `ServiceContext` for the length of a call.

Authentication receives a presented credential and returns an identity or throws. A call with
no credential never reaches the authenticator; requiring an identity is the application's
decision, as is deciding what an authenticated identity may do.

The credential and identity remain generic. swift-authentication-jwt verifies user tokens;
gRPC, Hummingbird, and Vapor adapters bind the resulting principal. mTLS secures service
connections, and user JWTs authenticate users. User handlers require the identity and pass it to
the owning use case for authorization. Internal operations accept business input directly.

## Example

A transport binds the principal; a handler reads it. An application usually spells the lookup
once:

```swift
extension ServiceContext {
    var caller: Principal<AppToken, String>? {
        self[PrincipalKey<AppToken, String>.self]
    }
}

guard let caller = ServiceContext.current?.caller?.identity else {
    throw RPCError(code: .unauthenticated, message: "Sign in to continue.")
}
```

A test that needs a bound caller uses the standard API:

```swift
var context = ServiceContext.topLevel
context[PrincipalKey<AppToken, String>.self] = Principal(identity: token, credential: "-")
try await ServiceContext.withValue(context) { try await useCase(input: input) }
```

## Topics

### Proving a credential

- ``Authenticator``
- ``CredentialIssuer``

### The principal it proves

- ``Principal``
- ``PrincipalKey``

### Design

- <doc:PrincipalsAndCredentials>
