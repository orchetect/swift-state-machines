//
//  StateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineProtocol<StateID>: ~Copyable {
    associatedtype StateID: Hashable, Sendable
    var stateWithResources: StateMachineStateWithResources<StateID> { get }

    init(stateWithResources: consuming StateMachineStateWithResources<StateID>)

    func update(stateWithResources: consuming StateMachineStateWithResources<StateID>)
}
