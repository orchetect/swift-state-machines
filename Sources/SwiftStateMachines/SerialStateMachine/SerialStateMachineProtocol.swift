//
//  SerialStateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol SerialStateMachineProtocol: StateMachineProtocol {
    func _lock() -> Bool
    func _unlock()
}

extension SerialStateMachineProtocol {
    public mutating func serialTransition<S: StateMachineState<StateID>>(to newState: S, resources: () -> S.StateResources) -> Bool {
        guard _lock() else { return false }
        defer { _unlock() }

        return transition(to: newState, resources: resources)
    }

    public mutating func serialTransition<S: StateMachineState<StateID>>(to newState: S) -> Bool where S.StateResources == Never {
        guard _lock() else { return false }
        defer { _unlock() }

        return transition(to: newState)
    }

    @_disfavoredOverload @discardableResult
    public mutating func serialTransition<S: StateMachineState<StateID>>(to newState: StateID, resources: () -> S.StateResources) -> Bool where S == StateID {
        guard _lock() else { return false }
        defer { _unlock() }

        return transition(to: newState, resources: resources)
    }

    @_disfavoredOverload @discardableResult
    public mutating func serialTransition<S: StateMachineState<StateID>>(to newState: StateID) -> Bool where S == StateID, S.StateResources == Never {
        guard _lock() else { return false }
        defer { _unlock() }

        return transition(to: newState)
    }
}
