//
//  StateMachineTransitionResult.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public enum StateMachineTransitionResult {
    case completed
    case failed
    case skipped
}

extension StateMachineTransitionResult: Equatable { }

extension StateMachineTransitionResult: Hashable { }

extension StateMachineTransitionResult: Sendable { }
