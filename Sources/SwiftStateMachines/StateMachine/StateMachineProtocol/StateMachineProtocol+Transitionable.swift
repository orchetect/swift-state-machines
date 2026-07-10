//
//  StateMachineProtocol+Transitionable.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    // MARK: Current State != Current State ID

    @discardableResult
    public func transition<NewState: TransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    @discardableResult
    public func transition<NewState: TransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState.StateResources == Never {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case .completed(resources: _):
            update(stateStorage: StateStorage(state: newState))
            return .completed
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    // MARK: Current State == Current State ID

    @_disfavoredOverload @discardableResult
    public func transition<NewState: TransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> where NewState == NewState.StateID {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    @_disfavoredOverload @discardableResult
    public func transition<NewState: TransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState == NewState.StateID, NewState.StateResources == Never {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case .completed(resources: _):
            update(stateStorage: StateStorage(state: newState))
            return .completed
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    // MARK: Current State != Current State ID

    @discardableResult
    public func transition<NewState: AsyncTransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) async throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> {
        let completion = try await newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    @discardableResult
    public func transition<NewState: AsyncTransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) async throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState.StateResources == Never {
        let completion = try await newState.transition(in: self)

        switch completion.wrapped {
        case .completed(resources: _):
            update(stateStorage: StateStorage(state: newState))
            return .completed
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    // MARK: Current State == Current State ID

    @_disfavoredOverload @discardableResult
    public func transition<NewState: AsyncTransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) async throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> where NewState == NewState.StateID {
        let completion = try await newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: anyResources):
            let newResources = anyResources.resourcesClosure()
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return .completed(resources: newResources)
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }

    @_disfavoredOverload @discardableResult
    public func transition<NewState: AsyncTransitionableStateMachineState<StateID>>(
        to newState: consuming NewState
    ) async throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState == NewState.StateID, NewState.StateResources == Never {
        let completion = try await newState.transition(in: self)

        switch completion.wrapped {
        case .completed(resources: _):
            update(stateStorage: StateStorage(state: newState))
            return .completed
        case .failed:
            return .failed
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return .failed
        case .skipped:
            return .skipped
        }
    }
}
