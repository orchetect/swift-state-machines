//
//  StartableObject.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Implements methods required by ``StartableObjectStateMachineState``.
public protocol StartableObject: SendableMetatype {
    associatedtype StartConfiguration: Sendable

    init()

    mutating func start(configuration: StartConfiguration) -> Bool

    func stop()
}
