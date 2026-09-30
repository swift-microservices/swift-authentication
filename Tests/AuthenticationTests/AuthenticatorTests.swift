//
//  AuthenticatorTests.swift
//  swift-authentication
//
//  Created by Zaid Rahhawi on 9/30/26.
//

import Authentication
import Testing

@Suite
struct AuthenticatorTests {
    struct Claims: Sendable, Equatable {
        let subject: String
    }

    enum AuthenticationFailure: Error {
        case unknownCredential
    }

    struct TokenAuthenticator: Authenticator {
        func authenticate(_ credential: String) throws -> Claims {
            guard credential == "alice-token" else {
                throw AuthenticationFailure.unknownCredential
            }
            return Claims(subject: "alice")
        }
    }

    let authenticator: any Authenticator<String, Claims> = TokenAuthenticator()

    @Test("Authenticating through the protocol returns an identity")
    func returnsIdentity() async throws {
        let identity: Claims = try await authenticator.authenticate("alice-token")

        #expect(identity == Claims(subject: "alice"))
    }

    @Test("A credential that cannot establish an identity throws through the protocol")
    func failureThrows() async {
        await #expect(throws: AuthenticationFailure.unknownCredential) {
            try await authenticator.authenticate("unknown-token")
        }
    }
}
