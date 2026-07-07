//
//  SerialStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public struct SerialStateMachine<StateID: Hashable & Sendable>: StateMachineProtocol, ~Copyable {
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

extension SerialStateMachine: SerialStateMachineProtocol {
    public mutating func withLock<E, T>(
        _ block: (_ stateMachine: inout Self) throws(E) -> T,
        lockFailure: () throws(E) -> T
    ) throws(E) -> T {
        guard _fenceLock() else { return try lockFailure() }
        defer { _fenceUnlock() }

        return try block(&self)
    }
}
