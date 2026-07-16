//
//  StateMachineStateComparisonResult.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public enum StateMachineStateComparisonResult {
    /// The states are equal, and the state has indicated that it cannot transition to itself.
    ///
    /// Attempting the transition will likely result in a 'skipped' result.
    case cannotTransitionAndIsEqual

    /// The state can attempt a transition to the incoming state.
    /// (The two states may or may not be equal.)
    ///
    /// Attempting the transition will either succeed as completed, or fail if any additional
    /// conditions are added during transition.
    case canTransition

    /// The state cannot a transition to the incoming state.
    /// (The two states may or may not be equal.)
    ///
    /// Attempting the transition will always fail.
    case cannotTransition
}

extension StateMachineStateComparisonResult: Equatable { }

extension StateMachineStateComparisonResult: Hashable { }

extension StateMachineStateComparisonResult: Sendable { }

// MARK: - Internal

extension StateMachineStateComparisonResult {
    /// Internal:
    /// If the state comparison result should deny the transition, this returns a non-`nil` result.
    var denialReason: StateMachineTransitionResult? {
        switch self {
        case .cannotTransitionAndIsEqual: .skipped
        case .canTransition: nil
        case .cannotTransition: .failed
        }
    }

    /// Internal:
    /// If the state comparison result should deny the transition, this returns a non-`nil` result.
    func denialReason<S: StateMachineState>(of stateType: S.Type = S.self) -> StateMachineResourcedTransitionResult<S>? {
        switch self {
        case .cannotTransitionAndIsEqual: .skipped
        case .canTransition: nil
        case .cannotTransition: .failed
        }
    }
}
