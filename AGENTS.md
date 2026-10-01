# Repository guidelines

This package is the authentication vocabulary shared by every service in the organization. Read
this before changing anything.

## What this package is

- One product, `Authentication`: `Authenticator`, `CredentialIssuer`, `Principal`, and
  `PrincipalKey`, generic over credential and identity. It depends only on swift-service-context.
- It knows no concrete credential or claims. swift-authentication-jwt proves user JWTs;
  swift-authentication-grpc, -hummingbird, and -vapor read bearer credentials and bind the
  resulting principal. These packages depend on this one by tag.
- `Authenticator.authenticate(_:) async throws -> Identity` returns a concrete identity or
  throws. Transports bind successful identities and translate authentication failures. A call
  with no credential never reaches the authenticator.
- User handlers require an identity, and owning use cases check user permissions and resource
  access. User principals and user database settings apply to user operations.
- Internal service and worker RPCs use mandatory transport mTLS and accept business input
  directly. Their use cases enforce business invariants. Public operations check their
  required credentials or proofs. Keep these audiences explicit in transport descriptors.

## What does not belong here

- Concrete credentials, cryptography, token claims, roles, or permission policies.
- Transport configuration or certificate lifecycle. Composition roots configure explicit mTLS
  trust and run certificate reloaders with transports; deployments issue and renew certificates.
- Reading headers or metadata. Each transport package reads its framework's types.

## Swift

- Swift 6.3, strict concurrency, `Sendable` everywhere it is meaningful.
- Tests use Swift Testing. The key is proven by binding and reading principals through
  `ServiceContext`, including two on one call.
- Doc comments on every public declaration; the DocC catalog is the long-form explanation.
- Format with `swift-format format --in-place --recursive Sources Tests`; the soundness check on
  every pull request runs the same rules, an API breakage check against the base branch, and
  shellcheck and yamllint.
- File headers follow the existing files: name, package, author, date.

## Releases

- Every pull request carries exactly one label: `⚠️ semver/major`, `🆕 semver/minor`,
  `🔨 semver/patch`, or `semver/none`. The label check blocks merging without one.
- Releases are GitHub Releases, created by the Auto Release workflow: run it by hand on `main`
  and it computes the next version from the labels of the pull requests merged since the last
  release, tags it, and writes the notes from `.github/release.yml`. A major bump is refused
  there and is cut by hand.
- Consumers pin by tag, never by branch or path.
