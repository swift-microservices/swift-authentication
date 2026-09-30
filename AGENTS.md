# Repository guidelines

This package is the authentication vocabulary shared by every service in the organization. Read
this before changing anything.

## What this package is

- One product, `Authentication`: `Authenticator`, `CredentialIssuer`, `Principal`, and
  `PrincipalKey`, all generic over the credential and the identity. It depends only on
  swift-service-context.
- It knows no credential. A token is a `String`, a certificate is a `Certificate`, and both are
  someone else's type. Proofs (swift-authentication-jwt, -x509) and transports
  (swift-authentication-grpc, -hummingbird, -vapor) are separate packages that depend on this
  one by tag.
- Nothing is named by who presented a credential. There is no "user" here: whether an identity
  is a person or a process is a claim the application reads.
- An authenticator receives a presented credential and returns an identity or throws. It never
  declines with `nil`. Transports bind successful identities and translate authentication
  failures; whether a call requires a caller is the application's decision. A call with no
  credential never reaches the authenticator.

## What does not belong here

- A concrete credential: a token type, a certificate type, a key type, a crypto dependency.
- Reading claims, roles, or permissions. The application decides what a principal may do.
- Anything about how a credential travels. Each transport package reads it with its own
  framework's types.

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
