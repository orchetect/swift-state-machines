//
//  StateMachineActorProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineActorProtocol: Actor, StateMachineProtocol {
    /// Access the state machine within a scoped exclusive lock.
    func withActor<E, T>(
        _ block: borrowing (_ stateMachine: borrowing Self) async throws(E) -> T
    ) async throws(E) -> T
}

// MARK: - Async

extension StateMachineActorProtocol where StateStorage == SendableStateMachineStateStorage<StateID> {
    public func withResources<S: StateMachineState<StateID>, T: Sendable, E>(
        for expectedState: sending S,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, T: Sendable, E>(
        for expectedState: S,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S.StateResources == Never {
        try await failureBlock()
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T: Sendable, E>(
        for expectedState: StateID,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S == StateID {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T: Sendable, E>(
        for expectedState: StateID,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S == StateID, S.StateResources == Never {
        try await failureBlock()
    }
}
