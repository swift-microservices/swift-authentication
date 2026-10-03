// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

/// A party a credential proved: the identity, and the credential that proved it.
///
/// The identity is the concrete value returned by the authenticator.
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
