//
//  StateMachineProtocol+WithResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable, E>(
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
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID {
        try stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID, S.StateResources == Never {
        try failureBlock()
    }
}

// MARK: - Non-Async Void Return

extension StateMachineProtocol where Self: ~Copyable {
    public func withResources<S: StateMachineState<StateID>, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> Void
    ) throws(E) -> Void {
        try stateStorage.withResources(for: expectedState, block, wrongState: { () throws(E) in })
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> Void
    ) throws(E) -> Void where S.StateResources == Never {
        // empty
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> Void
    ) throws(E) -> Void where S == StateID {
        try stateStorage.withResources(for: expectedState, block, wrongState: { () throws(E) in })
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> Void
    ) throws(E) -> Void where S == StateID, S.StateResources == Never {
        // empty
    }
}
