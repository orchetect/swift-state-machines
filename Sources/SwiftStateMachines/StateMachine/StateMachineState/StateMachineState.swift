//
//  StateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineState<StateID>: Copyable, SendableMetatype {
    associatedtype StateID: Hashable, Sendable, Copyable
    var stateID: StateID { get }

    associatedtype StateResources

    func canTransition(to newState: borrowing some StateMachineState<StateID>) -> Bool
}

// MARK: - Default Implementation

extension StateMachineState {
    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        true
    }
}

// MARK: - Methods

extension StateMachineState {
    /// Returns a state machine state comparison result describing whether two states are equal, or
    /// whether one state can transition into another.
    public func compare(to newState: some StateMachineState<StateID>) -> StateMachineStateComparisonResult {
        if canTransition(to: newState) {
            .canTransition
        } else {
            stateID == newState.stateID ? .cannotTransitionAndIsEqual : .cannotTransition
        }
    }
}
