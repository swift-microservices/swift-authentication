//
//  PrincipalKey.swift
//  swift-authentication
//
//  Created by Zaid Rahhawi on 9/11/26.
//

public import ServiceContextModule

/// The `ServiceContext` key under which a ``Principal`` of the current call is bound.
///
/// A transport binds it for the length of a call; a handler reads it without threading the
/// caller through every signature. The key is generic over both the identity and the credential,
/// so bindings with different identity or credential types remain independent.
///
/// An application usually spells the lookup once:
///
/// ```swift
/// extension ServiceContext {
///     var caller: Principal<AppToken, String>? {
///         self[PrincipalKey<AppToken, String>.self]
///     }
/// }
/// ```
public enum PrincipalKey<Identity: Sendable, Credential: Sendable>: ServiceContextKey {
    public typealias Value = Principal<Identity, Credential>

    public static var nameOverride: String? { "principal" }
}
