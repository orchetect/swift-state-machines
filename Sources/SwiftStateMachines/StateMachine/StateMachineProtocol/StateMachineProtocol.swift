//
//  StateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineProtocol<StateID>: ~Copyable where StateStorage.StateID == StateID {
    associatedtype StateID: Hashable, Sendable

    associatedtype StateStorage: StateMachineStateStorageProtocol

    var stateStorage: StateStorage { get }

    // init(stateStorage: consuming StateStorage)
    init<S: StateMachineState<StateID>>(initialState: consuming sending S, resources: consuming sending S.StateResources)
    init<S: StateMachineState<StateID>>(initialState: consuming sending S) where S.StateResources == Never

    func update(stateStorage: consuming StateStorage)
}
