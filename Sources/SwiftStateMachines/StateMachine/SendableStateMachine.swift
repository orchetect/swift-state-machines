//
//  SendableStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct SendableStateMachine<StateID: Hashable & Sendable>: StateMachineProtocol, Sendable, ~Copyable {
    public typealias StateID = StateID

    public typealias StateStorage = SendableStateMachineStateStorage<StateID>
    public let stateStorage: StateStorage

    init(stateStorage: consuming StateStorage) {
        self.stateStorage = stateStorage
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming sending S, resources: consuming sending S.StateResources) {
        self.init(stateStorage: StateStorage(state: initialState, resources: resources))
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming sending S) where S.StateResources == Never {
        self.init(stateStorage: StateStorage(state: initialState))
    }

    public func update(stateStorage: consuming StateStorage) {
        self.stateStorage.state = stateStorage.state
        self.stateStorage.resources = stateStorage.resources
    }
}
