# Principals and credentials

Carry a verified user identity and its original credential through a request.

## Authentication and binding

An ``Authenticator`` receives a presented credential and returns a concrete identity or throws.
The transport binds that identity and credential as a ``Principal`` under ``PrincipalKey`` in
`ServiceContext` for the call. Retaining the credential allows forwarding clients to present the
original token to the next service.

The protocol is generic over credential and identity. Supplied transports translate
verification failures into their unauthenticated response. A missing credential continues
unbound; user handlers require an identity before invoking the owning use case.

## Security boundaries

mTLS secures service-to-service connections. User JWTs authenticate users, and each receiving
service verifies the original token with the issuer's public key and the required claim checks.
The owning use case authorizes the user operation. User principals and database settings are
scoped to user descriptors; internal operations accept business input and enforce domain
invariants.

## Context scope

``PrincipalKey`` includes the identity and credential types, so differently typed bindings
remain independent. Transports preserve existing tracing and context values and restore the
enclosing principal when the request scope ends.
