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
    ) -> StateMachineTransitionResult {
        stateMachine.withLock { stateMachine in
            stateMachine.transition(to: .started()) {
                resources()
            }.genericResult
        } lockFailure: {
            .failed
        }
    }

    @discardableResult
    public func start(
        _ block: () -> Void
    ) -> StateMachineTransitionResult where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            let compareResult = stateMachine.stateStorage.state.compare(to: .started())
            if let denialReason = compareResult.denialReason { return denialReason }

            block()
            return stateMachine.transition(to: .started())
        } lockFailure: {
            .failed
        }
    }

    @_disfavoredOverload @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: consuming ((_ resources: inout StartedState.StateResources) -> Void)? = nil
    ) -> StateMachineTransitionResult {
        stateMachine.withLock { stateMachine in
            let compareResult = if isPermanent {
                stateMachine.stateStorage.state.compare(to: .stoppedPermanently())
            } else {
                stateMachine.stateStorage.state.compare(to: .stopped())
            }
            if let denialReason = compareResult.denialReason { return denialReason }

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
            return result
        } lockFailure: {
            .failed
        }
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: () -> Void
    ) -> StateMachineTransitionResult where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            let compareResult = if isPermanent {
                stateMachine.stateStorage.state.compare(to: .stoppedPermanently())
            } else {
                stateMachine.stateStorage.state.compare(to: .stopped())
            }
            if let denialReason = compareResult.denialReason { return denialReason }

            block()

            let result = isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
            return result
        } lockFailure: {
            .failed
        }
    }
}

// MARK: - Lifecycle (Async)

extension StartStopStateMachine {
    @_disfavoredOverload @discardableResult
    public func start<E>(
        resources: sending @escaping @isolated(any) () async throws(E) -> StartedStateMachineState<StartedResources>.StateResources
    ) async throws(E) -> StateMachineTransitionResult {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        return try await stateMachine.transition(to: .started()) { () async throws(E) in
            try await resources()
        }.genericResult
    }

    @_disfavoredOverload @discardableResult
    public func start<E>(
        resources: sending () async throws(E) -> StartedStateMachineState<StartedResources>.StateResources
    ) async throws(E) -> StateMachineTransitionResult {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        return try await stateMachine.transition(to: .started()) { () async throws(E) in
            try await resources()
        }.genericResult
    }

    @discardableResult
    public func start<E>(
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) -> StateMachineTransitionResult where StartedResources == Never {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        let compareResult = stateMachine.stateStorage.state.compare(to: .started())
        if let denialReason = compareResult.denialReason { return denialReason }

        try await block()
        return stateMachine.transition(to: .started())

    }

    @discardableResult
    public func start<E>(
        _ block: sending () async throws(E) -> Void
    ) async throws(E) -> StateMachineTransitionResult where StartedResources == Never {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        let compareResult = stateMachine.stateStorage.state.compare(to: .started())
        if let denialReason = compareResult.denialReason { return denialReason }

        try await block()
        return stateMachine.transition(to: .started())

    }

    @_disfavoredOverload @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        resourcesTeardown: sending (@isolated(any) (_ resources: inout StartedState.StateResources) async throws(E) -> Void)? = nil
    ) async throws(E) -> StateMachineTransitionResult {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        let compareResult = if isPermanent {
            stateMachine.stateStorage.state.compare(to: .stoppedPermanently())
        } else {
            stateMachine.stateStorage.state.compare(to: .stopped())
        }
        if let denialReason = compareResult.denialReason { return denialReason }

        if let resourcesTeardown {
            if var resources = stateMachine.resources(for: .started()) {
                try await resourcesTeardown(&resources)
            }
        }

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result
    }

    @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) -> StateMachineTransitionResult where StartedResources == Never {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        let compareResult = if isPermanent {
            stateMachine.stateStorage.state.compare(to: .stoppedPermanently())
        } else {
            stateMachine.stateStorage.state.compare(to: .stopped())
        }
        if let denialReason = compareResult.denialReason { return denialReason }

        try await block()

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result
    }

    @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        _ block: sending () async throws(E) -> Void
    ) async throws(E) -> StateMachineTransitionResult where StartedResources == Never {
        guard stateMachine._fenceLock() else { return .failed }
        defer { stateMachine._fenceUnlock() }

        let compareResult = if isPermanent {
            stateMachine.stateStorage.state.compare(to: .stoppedPermanently())
        } else {
            stateMachine.stateStorage.state.compare(to: .stopped())
        }
        if let denialReason = compareResult.denialReason { return denialReason }

        try await block()

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result
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
