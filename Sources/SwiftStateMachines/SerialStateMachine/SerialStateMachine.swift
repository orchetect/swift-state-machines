//
//  SerialStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public final class SerialStateMachine<StateID: Hashable & Sendable>: StateMachineProtocol {
    public typealias StateID = StateID

    nonisolated
    public var stateStorage: StateMachineStateStorage<StateID> {
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
    nonisolated(unsafe) private var _stateStorage: StateMachineStateStorage<StateID>

    nonisolated
    let stateStorageLock = NSLock()

    nonisolated
    let fenceLock = NSLock()

    nonisolated
    init(stateStorage: consuming StateMachineStateStorage<StateID>) {
        self._stateStorage = stateStorage
    }

    public convenience init<S: StateMachineState<StateID>>(initialState: consuming sending S, resources: consuming sending S.StateResources) {
        self.init(stateStorage: StateStorage(state: initialState, resources: resources))
    }

    public convenience init<S: StateMachineState<StateID>>(initialState: consuming sending S) where S.StateResources == Never {
        self.init(stateStorage: StateStorage(state: initialState))
    }

    nonisolated
    public func update(stateStorage: consuming StateMachineStateStorage<StateID>) {
        self.stateStorage = stateStorage
    }
}

extension SerialStateMachine: Sendable { }

extension SerialStateMachine {
    func _fenceLock() -> Bool {
        fenceLock.lock(before: .init())
    }

    func _fenceUnlock() {
        fenceLock.unlock()
    }
}

// MARK: - Lock Fence (Non-Async)

extension SerialStateMachine: SerialStateMachineProtocol {
    public func withLock<E, T>(
        _ block: (_ stateMachine: borrowing SerialStateMachine<StateID>) throws(E) -> T,
        lockFailure: () throws(E) -> T
    ) throws(E) -> T {
        guard _fenceLock() else { return try lockFailure() }
        defer { _fenceUnlock() }

        return try block(self)
    }
}

// MARK: - Lock Fence (Async)

extension SerialStateMachine {
    public func withLock<E, T>(
        _ block: borrowing (_ stateMachine: borrowing SerialStateMachine<StateID>) async throws(E) -> T,
        lockFailure: () async throws(E) -> T
    ) async throws(E) -> T {
        guard _fenceLock() else { return try await lockFailure() }
        defer { _fenceUnlock() }

        return try await block(self)
    }
}
