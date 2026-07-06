//
//  StartableActor.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Implements methods required by ``StartableActorStateMachineState``.
public protocol StartableActor: Actor, SendableMetatype {
    associatedtype StartConfiguration: Sendable

    init()

    func start(configuration: StartConfiguration) -> Bool

    func stop()
}
