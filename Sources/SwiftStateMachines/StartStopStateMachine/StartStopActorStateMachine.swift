//
//  StartStopActorStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StartStopActorStateMachine<StartedResources: Sendable>: ~Copyable {
    public typealias StartedState = StartedStateMachineState<StartedResources>
    public typealias StoppedState = StoppedStateMachineState<StartedResources>
    public typealias StoppedPermanentlyState = StoppedPermanentlyStateMachineState<StartedResources>

    nonisolated
    var stateMachine = StateMachineActor<StartStopStateID>(initialState: StoppedState())

    nonisolated
    public init() { }

    @_disfavoredOverload
    nonisolated
    public init() where StartedResources == Never { }
}

extension StartStopActorStateMachine: Sendable { }

// MARK: - Lifecycle

extension StartStopActorStateMachine {
    @_disfavoredOverload @discardableResult
    public func start(
        resources: sending @escaping @isolated(any) () async -> StartedStateMachineState<StartedResources>.StateResources
    ) async -> Bool {
        await stateMachine.withActor { stateMachine in
            await stateMachine.transition(to: .started()) {
                await resources()
            }
        }
    }

    @discardableResult
    public func start(
        _ block: sending @escaping @isolated(any) () async -> Void
    ) async -> Bool where StartedResources == Never {
        await stateMachine.withActor { stateMachine in
            await block()
            return stateMachine.transition(to: .started())
        }
    }

    @_disfavoredOverload @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: sending (@isolated(any) (_ resources: StartedState.StateResources) async -> Void)? = nil
    ) async -> Bool {
        await stateMachine.withActor { [resourcesTeardown] stateMachine in
            if let resourcesTeardown {
                await stateMachine.withResources(for: .started()) { [resourcesTeardown] resources in
                    // clean up resources
                    await resourcesTeardown(resources)
                } wrongState: {
                    // ignore
                }
            }

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        }
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: sending @escaping @isolated(any) () async -> Void
    ) async -> Bool where StartedResources == Never {
        await stateMachine.withActor { stateMachine in
            await block()

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        }
    }
}

// MARK: - Started Resources

extension StartStopActorStateMachine {
    public func withStartedResources<T /* : Sendable */, E>(
        _ block: sending @escaping /* @isolated(any) */ (_ resources: inout StartedState.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending @escaping /* @isolated(any) */ () async throws(E) -> T
    ) async throws(E) -> T {
        try await stateMachine.withResources(for: .started()) { resources async throws(E) -> T in
            try await block(&resources)
        } wrongState: { () async throws(E) in
            try await failureBlock()
        }
    }

    nonisolated
    public var startedResources: StartedState.StateResources? {
        stateMachine.resources(for: .started())
    }
}

// MARK: - State Asserts

extension StartStopActorStateMachine {
    nonisolated
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
