//
//  SerialStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public final class SerialStateMachine<StateID: Hashable & Sendable>: StateMachineProtocol {
    public typealias StateID = StateID

    nonisolated
    public var stateWithResources: StateMachineStateWithResources<StateID> {
        _read {
            stateWithResourcesLock.lock()
            defer { stateWithResourcesLock.unlock() }
            yield _stateWithResources
        }
        _modify {
            stateWithResourcesLock.lock()
            defer { stateWithResourcesLock.unlock() }
            yield &_stateWithResources
        }
    }
    nonisolated(unsafe) private var _stateWithResources: StateMachineStateWithResources<StateID>

    nonisolated
    let stateWithResourcesLock = NSLock()

    nonisolated
    let fenceLock = NSLock()

    nonisolated
    public init(stateWithResources: consuming StateMachineStateWithResources<StateID>) {
        self._stateWithResources = stateWithResources
    }

    nonisolated
    public func update(stateWithResources: consuming StateMachineStateWithResources<StateID>) {
        self.stateWithResources = stateWithResources
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
