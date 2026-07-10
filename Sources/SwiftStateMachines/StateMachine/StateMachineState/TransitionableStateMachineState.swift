//
//  TransitionableStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol TransitionableStateMachineState<StateID>: StateMachineState, Copyable {
    associatedtype TransitionFailure: Error

    func transition<StateMachine: StateMachineProtocol<StateID> & ~Copyable>(
        in stateMachine: borrowing StateMachine
    ) throws(TransitionFailure) -> StateMachineTransitionCompletion<Self>
}
