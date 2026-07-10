//
//  StateMachineProtocol+TransitionFromTo.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    // MARK: Current State != Current State ID

    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState>
    ) throws(E) -> StateMachineResourcedTransitionResult<NewState> {
        typealias Completion = StateMachineTransitionCompletion<NewState>

        guard stateStorage.state.canTransition(to: newState) else { return .failed }
        guard let completion: Completion = try withResources(for: currentState, { currentResources throws(E) in
            try resources(&currentResources)
        }, wrongState: { () throws(E) in
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
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState>
    ) throws(E) -> StateMachineResourcedTransitionResult<NewState> where CurrentState.StateResources == Never {
        .failed
    }

    // MARK: Current State == Current State ID

    @_disfavoredOverload @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState.StateID,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState>
    ) throws(E) -> StateMachineResourcedTransitionResult<NewState> where NewState == StateID {
        typealias Completion = StateMachineTransitionCompletion<NewState>

        guard stateStorage.state.canTransition(to: newState) else { return .failed }
        guard let completion: Completion = try withResources(for: currentState, { currentResources throws(E) in
            try resources(&currentResources)
        }, wrongState: { () throws(E) in
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
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState>
    ) throws(E) -> StateMachineResourcedTransitionResult<NewState> where NewState == StateID, CurrentState.StateResources == Never {
        .failed
    }
}
