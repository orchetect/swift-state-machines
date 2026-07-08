//
//  StateMachineActor.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public actor StateMachineActor<StateID: Hashable & Sendable>: StateMachineProtocol {
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

    public init(stateWithResources: consuming sending StateMachineStateWithResources<StateID>) {
        self._stateWithResources = stateWithResources
    }

    nonisolated
    public func update(stateWithResources: consuming StateMachineStateWithResources<StateID>) {
        self.stateWithResources = stateWithResources
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
