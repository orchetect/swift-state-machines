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
    public func start(
        resources: sending @escaping @isolated(any) () async -> StartedStateMachineState<StartedResources>.StateResources
    ) async -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        return await stateMachine.transition(to: .started()) {
            await resources()
        }.genericResult != .failed
    }

    @_disfavoredOverload @discardableResult
    public func start(
        resources: sending () async -> StartedStateMachineState<StartedResources>.StateResources
    ) async -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        return await stateMachine.transition(to: .started()) {
            await resources()
        }.genericResult != .failed
    }

    @discardableResult
    public func start(
        _ block: sending @escaping @isolated(any) () async -> Void
    ) async -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        await block()

        return stateMachine.transition(to: .started()) != .failed

    }

    @discardableResult
    public func start(
        _ block: sending () async -> Void
    ) async -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        await block()

        return stateMachine.transition(to: .started()) != .failed

    }

    @_disfavoredOverload @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: sending (@isolated(any) (_ resources: inout StartedState.StateResources) async -> Void)? = nil
    ) async -> Bool {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        if let resourcesTeardown {
            if var resources = stateMachine.resources(for: .started()) {
                await resourcesTeardown(&resources)
            }
        }

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result != .failed
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: sending @escaping @isolated(any) () async -> Void
    ) async -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        await block()

        let result = isPermanent
            ? stateMachine.transition(to: .stoppedPermanently())
            : stateMachine.transition(to: .stopped())
        return result != .failed
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: sending () async -> Void
    ) async -> Bool where StartedResources == Never {
        guard stateMachine._fenceLock() else { return false }
        defer { stateMachine._fenceUnlock() }

        await block()

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
