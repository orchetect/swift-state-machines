//
//  StateMachineActor.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public actor StateMachineActor<StateID: Hashable & Sendable>: StateMachineProtocol {
    public typealias StateID = StateID

    public typealias StateStorage = SendableStateMachineStateStorage<StateID>
    nonisolated
    public var stateStorage: StateStorage {
        _read {
            stateStorageLock.lock()
            defer { stateStorageLock.unlock() }
            yield _stateStorage
        }
        _modify {
            stateStorageLock.lock()
            defer { stateStorageLock.unlock() }
            yield &_stateStorage
        }
    }
    nonisolated(unsafe) private var _stateStorage: StateStorage

    nonisolated
    let stateStorageLock = NSLock()

    init(stateStorage: consuming sending StateStorage) {
        self._stateStorage = stateStorage
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming sending S, resources: consuming sending S.StateResources) {
        self.init(stateStorage: StateStorage(state: initialState, resources: resources))
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming sending S) where S.StateResources == Never {
        self.init(stateStorage: StateStorage(state: initialState))
    }

    nonisolated
    public func update(stateStorage: consuming StateStorage) {
        self.stateStorage = stateStorage
    }
}

extension StateMachineActor: Sendable { }

extension StateMachineActor: StateMachineActorProtocol {
    public func withActor<E, T>(
        _ block: borrowing (_ stateMachine: borrowing StateMachineActor<StateID>) async throws(E) -> T
    ) async throws(E) -> T {
        try await block(self)
    }
}
