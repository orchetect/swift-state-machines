//
//  StateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineProtocol<StateID>: Sendable, ~Copyable {
    associatedtype StateID: Hashable, Sendable
    var stateStorage: StateMachineStateStorage<StateID> { get }

    init(stateWithResources: consuming sending StateMachineStateStorage<StateID>)

    func update(stateWithResources: consuming StateMachineStateStorage<StateID>)
}
