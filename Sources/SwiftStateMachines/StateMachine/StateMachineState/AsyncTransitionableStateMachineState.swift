//
//  AsyncTransitionableStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol AsyncTransitionableStateMachineState<StateID>: TransitionableStateMachineState, Copyable {
    func transition<StateMachine: StateMachineProtocol<StateID> & ~Copyable>(
        in stateMachine: borrowing StateMachine
    ) async throws(TransitionFailure) -> StateMachineTransitionCompletion<Self>
}
