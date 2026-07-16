//
//  StateMachineProtocol+Transition.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: consuming S,
        resources: () throws(E) -> S.StateResources
    ) throws(E) -> StateMachineResourcedTransitionResult<S> {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason(of: S.self) { return denialReason }

        let newResources = try resources()
        update(stateStorage: StateStorage(state: newState, resources: newResources))
        return .completed(resources: newResources)
    }

    @discardableResult
    public func transition<S: StateMachineState<StateID>>(
        to newState: S
    ) -> StateMachineTransitionResult where S.StateResources == Never {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason { return denialReason }

        update(stateStorage: StateStorage(state: newState))
        return .completed
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: StateID,
        resources: () throws(E) -> S.StateResources
    ) throws(E) -> StateMachineResourcedTransitionResult<S> where S == StateID {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason(of: S.self) { return denialReason }

        let newResources = try resources()
        update(stateStorage: StateStorage(state: newState, resources: newResources))
        return .completed(resources: newResources)
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(
        to newState: StateID
    ) -> StateMachineTransitionResult where S == StateID, S.StateResources == Never {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason { return denialReason }

        update(stateStorage: StateStorage(state: newState))
        return .completed
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: S,
        resources: () async throws(E) -> S.StateResources
    ) async throws(E) -> StateMachineResourcedTransitionResult<S> {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason(of: S.self) { return denialReason }

        let newResources = try await resources()
        update(stateStorage: StateStorage(state: newState, resources: newResources))
        return .completed(resources: newResources)
    }

    @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: S
    ) async throws(E) -> StateMachineTransitionResult where S.StateResources == Never {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason { return denialReason }

        update(stateStorage: StateStorage(state: newState))
        return .completed
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: StateID,
        resources: () async throws(E) -> S.StateResources
    ) async throws(E) -> StateMachineResourcedTransitionResult<S> where S == StateID {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason(of: S.self) { return denialReason }

        let newResources = try await resources()
        update(stateStorage: StateStorage(state: newState, resources: newResources))
        return .completed(resources: newResources)
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>, E>(
        to newState: StateID
    ) async throws(E) -> StateMachineTransitionResult where S == StateID, S.StateResources == Never {
        let compareResult = stateStorage.state.compare(to: newState)
        if let denialReason = compareResult.denialReason { return denialReason }

        update(stateStorage: StateStorage(state: newState))
        return .completed
    }
}
