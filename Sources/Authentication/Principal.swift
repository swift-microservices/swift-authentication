//
//  Principal.swift
//  swift-authentication
//
//  Created by Zaid Rahhawi on 9/11/26.
//

/// A party a credential proved: the identity, and the credential that proved it.
///
/// The identity is whatever the authenticator returned, a person's claims or a process's name.
/// The credential is kept beside it so a service relaying the call can present the same one
/// onward.
public struct Principal<Identity: Sendable, Credential: Sendable>: Sendable {
    /// Who the credential proved.
    public let identity: Identity

    /// What proved it, as presented.
    public let credential: Credential

    public init(identity: Identity, credential: Credential) {
        self.identity = identity
        self.credential = credential
    }
}
