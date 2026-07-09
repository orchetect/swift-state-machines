//
//  StateMachineStateWithResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public final class StateMachineStateStorage<StateID: Hashable & Sendable>: Sendable {
    var state: any StateMachineState<StateID> {
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

    var resources: Any {
        get {
            resourcesLock.lock()
            defer { resourcesLock.unlock() }
            return _resources
        }
        set {
            resourcesLock.lock()
            defer { resourcesLock.unlock() }
            _resources = newValue
        }
    }
    nonisolated(unsafe) private var _resources: Any
    private let resourcesLock = NSLock()

    init<State: StateMachineState<StateID>>(state: State, resources: State.StateResources) {
        self._state = state
        self._resources = resources
    }

    init<State: StateMachineState<StateID>>(state: State) where State.StateResources == Never {
        self._state = state
        self._resources = ()
    }
}

// MARK: - Non-Async

extension StateMachineStateStorage {
    func withResources<State: StateMachineState<StateID>, T, E>(
        for expectedState: State,
        _ block: (_ resources: inout State.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        guard state is State else { return try failureBlock() }
        return try withUnsafeMutablePointer(to: &resources) { ptr throws(E) in
            try ptr.withMemoryRebound(to: State.StateResources.self, capacity: 1) { pointer throws(E) in
                try block(&pointer.pointee)
            }
        }
    }

    func resources<State: StateMachineState<StateID>>(for expectedState: State) -> State.StateResources? {
        guard state is State else { return nil }
        return (resources as! State.StateResources)
    }
}

// MARK: - Async

extension StateMachineStateStorage {
    func withResources<State: StateMachineState<StateID>, T, E>(
        for expectedState: State,
        _ block: (_ resources: inout State.StateResources) async throws(E) -> T,
        wrongState failureBlock: () async throws(E) -> T
    ) async throws(E) -> T {
        guard state is State else { return try await failureBlock() }
        let ptr = withUnsafeMutablePointer(to: &resources) { ptr in
            ptr.withMemoryRebound(to: State.StateResources.self, capacity: 1) { pointer in
                pointer
            }
        }

        return try await block(&ptr.pointee)
    }
}
