//
//  StateMachineProtocol+Transition.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: S, resources: () -> S.StateResources) -> Bool {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: resources()))
        return true
    }

    @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: S) -> Bool where S.StateResources == Never {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState))
        return true
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: StateID, resources: () -> S.StateResources) -> Bool where S == StateID {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: resources()))
        return true
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: StateID) -> Bool where S == StateID, S.StateResources == Never {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState))
        return true
    }
}

// MARK: - Async

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: S, resources: () async -> S.StateResources) async -> Bool {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: await resources()))
        return true
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: StateID, resources: () async -> S.StateResources) async -> Bool where S == StateID {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: await resources()))
        return true
    }
}
