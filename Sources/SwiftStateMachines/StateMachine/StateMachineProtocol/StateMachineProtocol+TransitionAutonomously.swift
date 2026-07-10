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
    ) throws(NewState.TransitionFailure) -> Bool where NewState: AutonomousStateMachineState {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return true
        case .failed:
            return false
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return false
        }
    }

    // MARK: Current State == Current State ID

    @discardableResult
    public func transition<NewState: StateMachineState<StateID>>(
        to newState: consuming NewState
    ) throws(NewState.TransitionFailure) -> Bool where NewState: AutonomousStateMachineState, NewState == NewState.StateID {
        let completion = try newState.transition(in: self)

        switch completion.wrapped {
        case let .completed(resources: newResources):
            update(stateStorage: StateStorage(state: newState, resources: newResources))
            return true
        case .failed:
            return false
        case let .failureState(storage: failureStorage):
            _update(stateStorage: failureStorage)
            return false
        }
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    #warning("TODO: add async variants")
}
