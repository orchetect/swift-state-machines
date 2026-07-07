//
//  StateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineState<StateID> {
    associatedtype StateID: Hashable, Sendable
    var stateID: StateID { get }

    associatedtype StateResources: Sendable

    func canTransition(to newState: some StateMachineState<StateID>) -> Bool
}
