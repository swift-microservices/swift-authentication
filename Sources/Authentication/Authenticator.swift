//
//  Authenticator.swift
//  swift-authentication
//
//  Created by Zaid Rahhawi on 9/11/26.
//

/// Turns a presented credential into the identity it proves.
///
/// A credential is whatever a call carried: a bearer token, a certificate. An authenticator knows
/// one kind, and either returns the identity it establishes or throws:
///
/// - **An identity.** The credential proved it, and the transport binds a ``Principal``.
/// - **A throw.** Authentication could not establish an accepted identity: a bad signature, an
///   expired claim, or a certificate with no identity in the configured trust domain.
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
