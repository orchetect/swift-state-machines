//
//  StateMachineProtocol+WithResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        try stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S.StateResources == Never {
        try failureBlock()
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID {
        try stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID, S.StateResources == Never {
        try failureBlock()
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: @isolated(any) (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: () async throws(E) -> T
    ) async throws(E) -> T {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: @isolated(any) (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: () async throws(E) -> T
    ) async throws(E) -> T where S.StateResources == Never {
        try await failureBlock()
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: @isolated(any) (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: () async throws(E) -> T
    ) async throws(E) -> T where S == StateID {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: @isolated(any) (_ resources: inout S.StateResources) async throws(E) -> T,
        wrongState failureBlock: () async throws(E) -> T
    ) async throws(E) -> T where S == StateID, S.StateResources == Never {
        try await failureBlock()
    }
}
