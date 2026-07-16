//
//  StartStopStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StartStopStateMachine<StartedResources: Sendable>: ~Copyable {
    public typealias StartedState = StartedStateMachineState<StartedResources>
    public typealias StoppedState = StoppedStateMachineState<StartedResources>
    public typealias StoppedPermanentlyState = StoppedPermanentlyStateMachineState<StartedResources>

    var stateMachine = SerialStateMachine<StartStopStateID>(initialState: StoppedState())

    public init() { }

    @_disfavoredOverload
    public init() where StartedResources == Never { }
}

extension StartStopStateMachine: Sendable { }

// MARK: - Lifecycle (Non-Async)

extension StartStopStateMachine {
    @_disfavoredOverload @discardableResult
    public func start(
        resources: () -> StartedStateMachineState<StartedResources>.StateResources
    ) -> Bool {
        stateMachine.withLock { stateMachine in
            stateMachine.transition(to: .started()) {
                resources()
            }.genericResult != .failed
        } lockFailure: {
            false
        }
    }

    @discardableResult
    public func start(
        _ block: () -> Void
    ) -> Bool where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            guard stateMachine.stateStorage.state.canTransition(to: .started()) else { return false }
            block()
            return stateMachine.transition(to: .started()) != .failed
        } lockFailure: {
            false
        }
    }

    @_disfavoredOverload @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: consuming ((_ resources: inout StartedState.StateResources) -> Void)? = nil
    ) -> Bool {
        stateMachine.withLock { stateMachine in
            if isPermanent {
                guard stateMachine.stateStorage.state.canTransition(to:.stoppedPermanently()) else { return false }
            } else {
                guard stateMachine.stateStorage.state.canTransition(to:.stopped()) else { return false }
            }

            if let resourcesTeardown {
                stateMachine.withResources(for: .started()) { resources in
                    // clean up resources
                    resourcesTeardown(&resources)
                } wrongState: {
                    // ignore
                }
            }

            let result = isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
            return result != .failed
        } lockFailure: {
            false
        }
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: () -> Void
    ) -> Bool where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            if isPermanent {
                guard stateMachine.stateStorage.state.canTransition(to:.stoppedPermanently()) else { return false }
            } else {
                guard stateMachine.stateStorage.state.canTransition(to:.stopped()) else { return false }
            }
            
            block()

            let result = isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
            return result != .failed
        } lockFailure: {
            false
        }
    }
}

// MARK: - Lifecycle (Async)

extension StartStopStateMachine {
    @_disfavoredOverload @discardableResult
    public func start<E>(
        resources: sending @escaping @isolated(any) () async throws(E) -> StartedStateMachineState<StartedResources>.StateResources
    ) async throws(E) -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        return try await stateMachine.transition(to: .started()) { () async throws(E) in
            try await resources()
        }.genericResult != .failed
    }

    @_disfavoredOverload @discardableResult
    public func start<E>(
        resources: sending () async throws(E) -> StartedStateMachineState<StartedResources>.StateResources
    ) async throws(E) -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        return try await stateMachine.transition(to: .started()) { () async throws(E) in
            try await resources()
        }.genericResult != .failed
    }

    @discardableResult
    public func start<E>(
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        guard stateMachine.stateStorage.state.canTransition(to: .started()) else { return false }

        try await block()

        return stateMachine.transition(to: .started()) != .failed

    }

    @discardableResult
    public func start<E>(
        _ block: sending () async throws(E) -> Void
    ) async throws(E) -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        guard stateMachine.stateStorage.state.canTransition(to: .started()) else { return false }

        try await block()

        return stateMachine.transition(to: .started()) != .failed

    }

    @_disfavoredOverload @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        resourcesTeardown: sending (@isolated(any) (_ resources: inout StartedState.StateResources) async throws(E) -> Void)? = nil
    ) async throws(E) -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        if isPermanent {
            guard stateMachine.stateStorage.state.canTransition(to: .stoppedPermanently()) else { return false }
        } else {
            guard stateMachine.stateStorage.state.canTransition(to: .stopped()) else { return false }
        }

        if let resourcesTeardown {
            if var resources = stateMachine.resources(for: .started()) {
                try await resourcesTeardown(&resources)
            }
        }

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result != .failed
    }

    @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        if isPermanent {
            guard stateMachine.stateStorage.state.canTransition(to: .stoppedPermanently()) else { return false }
        } else {
            guard stateMachine.stateStorage.state.canTransition(to: .stopped()) else { return false }
        }

        try await block()

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result != .failed
    }

    @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        _ block: sending () async throws(E) -> Void
    ) async throws(E) -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        if isPermanent {
            guard stateMachine.stateStorage.state.canTransition(to: .stoppedPermanently()) else { return false }
        } else {
            guard stateMachine.stateStorage.state.canTransition(to: .stopped()) else { return false }
        }

        try await block()

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result != .failed
    }
}

// MARK: - Started Resources (Non-Async)

extension StartStopStateMachine {
    public func withStartedResources<T, E>(
        _ block: (_ resources: inout StartedState.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        try stateMachine.withResources(for: .started()) { resources throws(E) -> T in
            try block(&resources)
        } wrongState: { () throws(E) in
            try failureBlock()
        }
    }

    public var startedResources: StartedState.StateResources? {
        stateMachine.resources(for: .started())
    }
}

// MARK: - State Asserts

extension StartStopStateMachine {
    public func assertState(is state: StartStopStateID<StartedResources>) -> Bool {
        switch state {
        case .started:
            stateMachine.assertState(is: .started())
        case .stopped:
            stateMachine.assertState(is: .stopped())
        case .stoppedPermanently:
            stateMachine.assertState(is: .stoppedPermanently())
        }
    }
}
