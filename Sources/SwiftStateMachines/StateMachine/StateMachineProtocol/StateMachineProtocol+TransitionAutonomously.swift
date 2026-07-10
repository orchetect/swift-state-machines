//
//  StateMachineProtocol+TransitionAutonomously.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    // MARK: Current State != Current State ID

    @discardableResult
    public func transition<NewState: StateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> where NewState: AutonomousStateMachineState {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
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
    public func transition<NewState: StateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState: AutonomousStateMachineState, NewState.StateResources == Never {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
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
    public func transition<NewState: StateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineResourcedTransitionResult<NewState> where NewState: AutonomousStateMachineState, NewState == NewState.StateID {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
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
    public func transition<NewState: StateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> StateMachineTransitionResult where NewState: AutonomousStateMachineState, NewState == NewState.StateID, NewState.StateResources == Never {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
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
    #warning("TODO: add async variants")
}
