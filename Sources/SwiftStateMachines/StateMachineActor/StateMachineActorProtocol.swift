//
//  StateMachineActorProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineActorProtocol: Actor, StateMachineProtocol {
    /// Access the state machine within a scoped exclusive lock.
    func withActor<E, T>(
        _ block: sending (_ stateMachine: borrowing Self) async throws(E) -> T
    ) async throws(E) -> T
}
