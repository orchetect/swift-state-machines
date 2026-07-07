//
//  StateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StateMachine<StateID: Hashable & Sendable>: StateMachineProtocol, ~Copyable {
    public typealias StateID = StateID
    public var stateWithResources: StateMachineStateWithResources<StateID>

    public init(stateWithResources: consuming StateMachineStateWithResources<StateID>) {
        self.stateWithResources = stateWithResources
    }
}
