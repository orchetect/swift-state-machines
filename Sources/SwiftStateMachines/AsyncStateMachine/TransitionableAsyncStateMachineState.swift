//
//  TransitionableAsyncStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Contains a state machine state or a state of transitioning between states.
public enum TransitionableAsyncStateMachineState<State: AsyncStateMachineState> {
    /// Current state.
    case state(State)

    /// Currently in the process of transitioning to a new state.
    case transitioning(fromState: State, toState: State)
}

extension TransitionableAsyncStateMachineState: Equatable where State: Equatable { }

extension TransitionableAsyncStateMachineState: Hashable where State: Hashable { }

extension TransitionableAsyncStateMachineState: Sendable { }

// MARK: - Convenience Operators

extension TransitionableAsyncStateMachineState where Self: Equatable {
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

extension TransitionableAsyncStateMachineState {
    public var currentState: State {
        switch self {
        case let .state(state):
            state
        case let .transitioning(fromState, _):
            fromState
        }
    }
}
