//
//  Authenticator.swift
//  swift-authentication
//
//  Created by Zaid Rahhawi on 9/11/26.
//

/// Turns a presented credential into the identity it proves.
///
/// A credential is whatever a call carried: a bearer token, a certificate. An authenticator knows
/// one kind, and answers one of three ways:
///
/// - **An identity.** The credential proved it, and the transport binds a ``Principal``.
/// - **`nil`.** The credential names nobody this authenticator recognises, such as a certificate
///   from another trust domain. The call continues unbound, because a valid credential this
///   service does not admit is not an error.
/// - **A throw.** The credential was presented and does not verify: a bad signature, an expired
///   claim. The transport refuses the call, because absent and invalid are not the same thing.
///
/// Where the credential is read from, and where the identity is bound, is a transport's
/// business. What a proven identity may do is the application's.
public protocol Authenticator<Credential, Identity>: Sendable {
    associatedtype Credential: Sendable
    associatedtype Identity: Sendable

    /// The identity `credential` proves, `nil` to decline it, or a throw to refuse it.
    func authenticate(_ credential: Credential) async throws -> Identity?
}
