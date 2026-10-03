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
- Use the checked-in `.swift-format`, copied exactly from apple/swift-temporal-sdk at
  `508797b5468dbc532f77c317bf9df0cb3231f5c1`: four-space indentation, 150-column lines,
  and ordered imports. Format all tracked Swift files, including `Package.swift`, and run
  `swift-format lint --strict`. Public documentation remains a repository requirement even
  though this formatter does not enforce it.
- File headers use the compact license format documented below.

## Releases

- Every pull request carries exactly one label: `⚠️ semver/major`, `🆕 semver/minor`,
  `🔨 semver/patch`, or `semver/none`. The label check blocks merging without one.
- Releases are GitHub Releases, created by the Auto Release workflow: run it by hand on `main`
  and it computes the next version from the labels of the pull requests merged since the last
  release, tags it, and writes the notes from `.github/release.yml`. A major bump is refused
  there and is cut by hand.
- Consumers pin by tag, never by branch or path.

## Library CI profile

- This repository profile overrides general service CI and formatting defaults. Libraries
  never commit `Package.resolved`; CI resolves released dependencies from the manifest.
- PRs run documentation, formatting, compact license-header, shellcheck, and yamllint checks.
  Automatic API-breakage checking is disabled by project choice; SemVer labels still describe
  the public API impact. The docs workflow adds the DocC plugin only in its temporary checkout.
- PRs and main pushes run Linux tests on Swift 6.3 and 6.4, next/main snapshots, release builds,
  and x86_64/ARM64 static Linux SDK builds. CI has no scheduled runs. Require supported stable
  checks in branch protection; snapshot failures remain visible and advisory unless maintainers
  explicitly require them.
- Static SDK checks cross-compile only; they do not run ARM64 tests. Serialize ARM64 after
  x86_64 because SwiftNIO shares their concurrency group; run it even after x86_64 failure
  unless the workflow was canceled.
- CI is Linux-only by project choice. macOS and other Apple-platform builds/tests are
  outside this pipeline; Linux success does not establish Apple-platform compatibility.
- Shared library workflows and the SwiftNIO SemVer action follow `@main` by project choice.
  Soundness uses its release tag, and standard Actions use major-version tags. These moving
  references include upstream changes; do not describe them as immutable.
- Dependabot checks weekly, targets main, and labels workflow-update PRs `semver/none`.
- Use the three-line MIT header matched by `.license_header_template`. Keep the tools-version
  directive first in `Package.swift`, followed by that header. `.licenseignore` excludes the
  manifest (the upstream checker requires a header at line one) and the plain-text `LICENSE`.
- Keep the separate Foundation-linking consumer check on Swift 6.3 and 6.4 Noble; a successful
  static SDK build does not prove that the resolved graph avoids full Foundation.
