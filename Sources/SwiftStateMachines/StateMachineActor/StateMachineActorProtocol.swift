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

// MARK: - Async

extension StateMachineActorProtocol where StateStorage == SendableStateMachineStateStorage<StateID> {
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable & Sendable, E>(
        for expectedState: sending S,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> sending T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable & Sendable, E>(
        for expectedState: S,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> sending T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S.StateResources == Never {
        try await failureBlock()
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable & Sendable, E>(
        for expectedState: StateID,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> sending T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S == StateID {
        try await stateStorage.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T: ~Copyable & Sendable, E>(
        for expectedState: StateID,
        _ block: sending (_ resources: inout S.StateResources) async throws(E) -> sending T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T where S == StateID, S.StateResources == Never {
        try await failureBlock()
    }
}

// MARK: - Async

extension StateMachineActorProtocol where Self.StateStorage == SendableStateMachineStateStorage<StateID> {
    // MARK: Current State != Current State ID

    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: consuming NewState,
        resources: sending (_ currentResources: inout CurrentState.StateResources) async throws(E) -> sending StateMachineTransitionCompletion<NewState>
    ) async throws(E) -> StateMachineResourcedTransitionResult<NewState> where NewState.StateResources: Sendable {
        typealias Completion = StateMachineTransitionCompletion<NewState>

        guard stateStorage.state.canTransition(to: newState) else { return .failed }
        guard let completion: Completion = try await withResources(for: currentState, { currentResources async throws(E) in
            try await resources(&currentResources)
        }, wrongState: { () async throws(E) in
            nil
        }) else {
            return .failed
        }

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            guard stateStorage.state.canTransition(to: failureStorage.state) else { return .failed }
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .failed
        }
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState,
        resources: (_ currentResources: inout CurrentState.StateResources) async throws(E) -> StateMachineTransitionCompletion<NewState>
    ) async throws(E) -> StateMachineResourcedTransitionResult<NewState> where CurrentState.StateResources == Never {
        .failed
    }

    // MARK: Current State == Current State ID

    @_disfavoredOverload @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState.StateID,
        resources: (_ currentResources: inout CurrentState.StateResources) async throws(E) -> StateMachineTransitionCompletion<NewState>
    ) async throws(E) -> StateMachineResourcedTransitionResult<NewState> where NewState.StateResources: Sendable, NewState == StateID {
        typealias Completion = StateMachineTransitionCompletion<NewState>

        guard stateStorage.state.canTransition(to: newState) else { return .failed }
        guard let completion: Completion = try await withResources(for: currentState, { currentResources async throws(E) in
            try await resources(&currentResources)
        }, wrongState: { () async throws(E) in
            nil
        }) else {
            return .failed
        }

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            guard stateStorage.state.canTransition(to: failureStorage.state) else { return .failed }
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .failed
        }
    }

    @_disfavoredOverload @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState.StateID,
        resources: (_ currentResources: inout CurrentState.StateResources) async throws(E) -> StateMachineTransitionCompletion<NewState>
    ) async throws(E) -> StateMachineResourcedTransitionResult<NewState> where NewState == StateID, CurrentState.StateResources == Never {
        .failed
    }
}
