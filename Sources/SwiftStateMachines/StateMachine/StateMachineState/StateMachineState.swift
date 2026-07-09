//
//  StateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineState<StateID>: Copyable {
    associatedtype StateID: Hashable, Sendable, Copyable
    var stateID: StateID { get }

    associatedtype StateResources // : Sendable

    func canTransition(to newState: borrowing some StateMachineState<StateID>) -> Bool
}
