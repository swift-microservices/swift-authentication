// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import Authentication
import OperationContext
import Testing

@Suite
struct PrincipalTests {
    struct Claims: Sendable, Equatable {
        let subject: String
    }

    struct Workload: Sendable, Equatable {
        let name: String
    }

    @Test("A principal bound under its key is read back for the length of the call")
    func boundPrincipalIsReadBack() {
        var context = OperationContext()
        context[PrincipalKey<Claims, String>.self] = Principal(identity: Claims(subject: "alice"), credential: "token")

        let principal = OperationContext.withContext(context) {
            OperationContext.current[PrincipalKey<Claims, String>.self]
        }

        #expect(principal?.identity == Claims(subject: "alice"))
        #expect(principal?.credential == "token")
        #expect(OperationContext.current[PrincipalKey<Claims, String>.self] == nil)
    }

    @Test("Principals of different identities or credentials are bound under different keys")
    func keysAreDistinctPerIdentityAndCredential() {
        var context = OperationContext()
        context[PrincipalKey<Claims, String>.self] = Principal(identity: Claims(subject: "alice"), credential: "token")
        context[PrincipalKey<Workload, String>.self] = Principal(identity: Workload(name: "billing-worker"), credential: "service-token")
        context[PrincipalKey<Workload, Int>.self] = Principal(identity: Workload(name: "billing-worker"), credential: 7)

        let (person, workload, other) = OperationContext.withContext(context) {
            (
                OperationContext.current[PrincipalKey<Claims, String>.self]?.credential,
                OperationContext.current[PrincipalKey<Workload, String>.self]?.credential,
                OperationContext.current[PrincipalKey<Workload, Int>.self]?.credential
            )
        }

        #expect(person == "token")
        #expect(workload == "service-token")
        #expect(other == 7)
    }
}
