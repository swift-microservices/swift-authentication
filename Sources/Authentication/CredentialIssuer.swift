// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

/// Mints the credential that proves an identity.
///
/// The counterpart of ``Authenticator``: one process holds the private key and issues, every
/// other holds the public key and authenticates. Both are written against the identity they
/// carry, not against a credential format, so the transports never learn which is in use.
public protocol CredentialIssuer<Identity, Credential>: Sendable {
    associatedtype Identity: Sendable
    associatedtype Credential: Sendable

    /// The credential that proves `identity`.
    func issue(for identity: Identity) async throws -> Credential
}
