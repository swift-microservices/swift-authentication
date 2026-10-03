// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

/// Turns a presented credential into the identity it proves.
///
/// The credential and identity are generic. An authenticator knows one credential kind and
/// either returns the identity it establishes or throws:
///
/// - **An identity.** The credential proved it, and the transport binds a ``Principal``.
/// - **A throw.** Authentication could not establish an accepted identity: a bad signature, an
///   expired claim, or another invalid proof.
///
/// Where the credential is read from, and where the identity is bound, is a transport's
/// business. A call with no credential never reaches the authenticator. Whether a call requires
/// an identity, and what a proven identity may do, are the application's decisions.
public protocol Authenticator<Credential, Identity>: Sendable {
    associatedtype Credential: Sendable
    associatedtype Identity: Sendable

    /// Returns the identity `credential` establishes, or throws if authentication fails.
    func authenticate(_ credential: Credential) async throws -> Identity
}
