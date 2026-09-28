# Principals and credentials

One shape for every credential, named by what was presented, never by who presented it.

## Two credentials, one shape

A call can carry two kinds of proof. A token, in the `Authorization` metadata or header,
verified by a key the process holds. A certificate, presented at the TLS handshake and verified
by the transport before any byte of the request is read.

Both follow the same path. Something reads the credential off the call. An ``Authenticator``
turns it into an identity. The identity and the credential become a ``Principal``, bound under a
``PrincipalKey`` for the length of the call. This module is that path with the credential left
generic; the proof and transport packages fill it in.

## Three answers

An authenticator answers one of three ways, and the transports treat them differently:

- **An identity** binds a principal.
- **`nil`** declines. The credential names nobody this service recognises, such as a certificate
  from another trust domain. The call continues unbound, because a valid credential this service
  does not admit is not an error.
- **A throw** refuses. The credential was presented and does not verify. The call fails as
  unauthenticated, because absent and invalid are not the same thing.

A call with no credential at all never reaches the authenticator and continues anonymously; open
routes such as signing in have no caller yet. Requiring a caller is the handler's decision.

## An identity is not a person

Whether a principal is a person or a process is the application's reading of the identity, not
this module's. A person usually presents a token; a worker or a service calling with no person
behind it presents its certificate, and is named by it rather than by a token of its own.
Nothing here says "user", and nothing reads the claims. Roles travel in the identity and the
application decides what they permit.

## Two principals on one call

A service relaying a person's call arrives with its own certificate and the person's token. The
key is generic over both the identity and the credential, so the two principals are bound
independently and a handler can ask either question: which process is calling, and on whose
behalf.
