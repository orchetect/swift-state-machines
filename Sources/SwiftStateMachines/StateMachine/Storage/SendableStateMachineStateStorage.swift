//
//  SendableStateMachineStateStorage.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public final class SendableStateMachineStateStorage<StateID: Hashable & Sendable>: StateMachineStateStorageProtocol, Sendable {
    nonisolated
    public var state: any StateMachineState<StateID> {
        get {
            stateLock.lock()
            defer { stateLock.unlock() }
            return _state
        }
        set {
            stateLock.lock()
            defer { stateLock.unlock() }
            _state = newValue
        }
    }
    nonisolated(unsafe) private var _state: any StateMachineState<StateID>
    private let stateLock = NSLock()

    nonisolated
    public var resources: Any {
        get {
            resourcesLock.lock()
            defer { resourcesLock.unlock() }
            return _resources
        }
        _modify {
            resourcesLock.lock()
            defer { resourcesLock.unlock() }
            yield &_resources
        }
        set {
            resourcesLock.lock()
            defer { resourcesLock.unlock() }
            _resources = newValue
        }
    }
    nonisolated(unsafe) private var _resources: Any
    private let resourcesLock = NSLock()

    public init<State: StateMachineState<StateID>>(state: consuming State, resources: consuming State.StateResources) {
        self._state = state
        self._resources = resources
    }

    public init<State: StateMachineState<StateID>>(state: consuming State) where State.StateResources == Never {
        self._state = state
        self._resources = ()
    }
}

// MARK: - Async

extension SendableStateMachineStateStorage {
    func withResources<State: StateMachineState<StateID>, T: ~Copyable, E>(
        for expectedState: State,
        _ block: sending (_ resources: inout State.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending () async throws(E) -> T
    ) async throws(E) -> T {
        guard state is State else { return try await failureBlock() }

        // making a copy is not ideal but it's the safest
        var copy = resources as! State.StateResources
        defer { resources = copy }

        return try await block(&copy)
    }
}
