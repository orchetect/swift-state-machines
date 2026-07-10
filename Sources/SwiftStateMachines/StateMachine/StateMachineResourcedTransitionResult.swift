//
//  StateMachineResourcedTransitionResult.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public enum StateMachineResourcedTransitionResult<State: StateMachineState> {
    case completed(resources: State.StateResources)
    case failed
    case skipped
}

extension StateMachineResourcedTransitionResult: Equatable where State.StateResources: Equatable { }

extension StateMachineResourcedTransitionResult: Hashable where State.StateResources: Hashable { }

extension StateMachineResourcedTransitionResult: Sendable where State.StateResources: Sendable { }

extension StateMachineResourcedTransitionResult {
    public var genericResult: StateMachineTransitionResult {
        switch self {
        case .completed(_): .completed
        case .failed: .failed
        case .skipped: .skipped
        }
    }
}
