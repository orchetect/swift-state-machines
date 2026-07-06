//
//  TransitionableStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Contains a state machine state or a state of transitioning between states.
public enum TransitionableStateMachineState<State: StateMachineState> {
    /// Current state.
    case state(State)

    /// Currently in the process of transitioning to a new state.
    case transitioning(fromState: State, toState: State)
}

extension TransitionableStateMachineState: Equatable where State: Equatable { }

extension TransitionableStateMachineState: Hashable where State: Hashable { }

extension TransitionableStateMachineState: Sendable { }

// MARK: - Convenience Operators

extension TransitionableStateMachineState where Self: Equatable {
    public static func == (lhs: Self, rhs: State) -> Bool {
        switch lhs {
        case let .state(lhsState):
            lhsState == rhs
        case .transitioning(fromState: _, toState: _):
            false
        }
    }

    public static func != (lhs: Self, rhs: State) -> Bool {
        !(lhs == rhs)
    }
}

// MARK: - Properties

extension TransitionableStateMachineState {
    public var currentState: State {
        switch self {
        case let .state(state):
            state
        case let .transitioning(fromState, _):
            fromState
        }
    }
}
