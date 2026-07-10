//
//  StateMachineProtocol+TransitionWithResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState, StateStorage>
    ) throws(E) -> Bool {
        typealias Completion = StateMachineTransitionCompletion<NewState, StateStorage>

        guard stateStorage.state.canTransition(to: newState) else { return false }
        guard let completion: Completion = try withResources(for: currentState, { currentResources throws(E) in
            try resources(&currentResources)
        }, wrongState: { () throws(E) in
            nil
        }) else {
            return false
        }

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return true
        case .failed:
            return false
        case let .failureState(stateStorage):
            update(stateStorage: stateStorage)
            return false
        }
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState, StateStorage>
    ) throws(E) -> Bool where CurrentState.StateResources == Never {
        false
    }

    @_disfavoredOverload @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState.StateID,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState, StateStorage>
    ) throws(E) -> Bool where NewState == StateID {
        typealias Completion = StateMachineTransitionCompletion<NewState, StateStorage>

        guard stateStorage.state.canTransition(to: newState) else { return false }
        guard let completion: Completion = try withResources(for: currentState, { currentResources throws(E) in
            try resources(&currentResources)
        }, wrongState: { () throws(E) in
            nil
        }) else {
            return false
        }

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return true
        case .failed:
            return false
        case let .failureState(stateStorage):
            update(stateStorage: stateStorage)
            return false
        }
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload @discardableResult
    public func transition<NewState: StateMachineState<StateID>, CurrentState: StateMachineState<StateID>, E>(
        from currentState: consuming CurrentState,
        to newState: NewState.StateID,
        resources: (_ currentResources: inout CurrentState.StateResources) throws(E) -> StateMachineTransitionCompletion<NewState, StateStorage>
    ) throws(E) -> Bool where NewState == StateID, CurrentState.StateResources == Never {
        false
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    #warning("TODO: add async variants")
}
