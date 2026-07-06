//
//  StateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineState: Sendable {
    associatedtype Context: Sendable

    static var defaultContext: Context { get }

    /// Return a boolean value describing whether `self` can transition to `other`.
    func canTransition(to newState: Self, context: inout Context) -> Bool

    /// Called by the state machine when it is about to transition to a new state.
    /// Return a boolean value describing whether `self` should transition to `other`.
    func willTransition(to newState: Self, context: inout Context) -> Bool

    /// Called by the state machine after it has transitioned to a new state.
    func didTransition(to newState: Self, context: inout Context)
}

// MARK: - Convenience Operators

extension StateMachineState where Self: Equatable {
    public static func == (lhs: Self, rhs: TransitionableStateMachineState<Self>) -> Bool {
        switch rhs {
        case let .state(rhsState):
            lhs == rhsState
        case .transitioning(fromState: _, toState: _):
            false
        }
    }

    public static func != (lhs: Self, rhs: TransitionableStateMachineState<Self>) -> Bool {
        !(lhs == rhs)
    }
}
