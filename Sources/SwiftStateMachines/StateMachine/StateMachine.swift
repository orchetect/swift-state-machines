//
//  StateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StateMachine<StateID: Hashable & Sendable>: StateMachineProtocol, ~Copyable {
    public typealias StateID = StateID
    public let stateStorage: StateMachineStateStorage<StateID>

    public init(stateWithResources: consuming StateMachineStateStorage<StateID>) {
        self.stateStorage = stateWithResources
    }

    public func update(stateWithResources: consuming StateMachineStateStorage<StateID>) {
        self.stateStorage.state = stateWithResources.state
        self.stateStorage.resources = stateWithResources.resources
    }
}
