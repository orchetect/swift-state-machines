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
    public func start<E>(
        resources: sending @escaping @isolated(any) () async throws(E) -> StartedStateMachineState<StartedResources>.StateResources
    ) async throws(E) -> Bool {
        guard stateMachine.stateStorage.state.canTransition(to: .started()) else { return false }

        let result = try await stateMachine.withActor { stateMachine async throws(E) in
            return try await stateMachine.transition(to: .started()) { () async throws(E) in
                try await resources()
            }
        }

        return switch result {
        case .completed, .skipped: true
        case .failed: false
        }
    }

    @discardableResult
    public func start<E>(
        _ block: sending @escaping @isolated(any) () async throws(E) -> Bool
    ) async throws(E) -> Bool where StartedResources == Never {
        guard stateMachine.stateStorage.state.canTransition(to: .started) else { return false }

        let result = try await stateMachine.withActor { stateMachine async throws(E) in
            guard try await block() else { return false }

            let transitionResult = stateMachine.transition(to: .started())
            let isTransitionSuccess = switch transitionResult {
            case .completed, .skipped: true
            case .failed: false
            }
            return isTransitionSuccess
        }

        return result
    }

    @_disfavoredOverload @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        resourcesTeardown: sending (@isolated(any) (_ resources: inout StartedState.StateResources) async throws(E) -> Void)? = nil
    ) async throws(E) -> Bool {
        if isPermanent {
            guard stateMachine.stateStorage.state.canTransition(to:.stoppedPermanently()) else { return false }
        } else {
            guard stateMachine.stateStorage.state.canTransition(to:.stopped()) else { return false }
        }

        let result = try await stateMachine.withActor { [resourcesTeardown] stateMachine async throws(E) in
            if let resourcesTeardown {
                if var resources = stateMachine.resources(for: .started()) {
                    try await resourcesTeardown(&resources)
                }
            }

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        }

        return switch result {
        case .completed, .skipped: true
        case .failed: false
        }
    }

    @discardableResult
    public func stop<E>(
        permanently isPermanent: Bool = false,
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) -> Bool where StartedResources == Never {
        if isPermanent {
            guard stateMachine.stateStorage.state.canTransition(to:.stoppedPermanently()) else { return false }
        } else {
            guard stateMachine.stateStorage.state.canTransition(to:.stopped()) else { return false }
        }

        let result = try await stateMachine.withActor { stateMachine async throws(E) in
            try await block()

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        }

        return switch result {
        case .completed, .skipped: true
        case .failed: false
        }
    }
}

// MARK: - Started Resources

extension StartStopActorStateMachine {
    public func withStartedResources<T: Sendable, E>(
        _ block: sending @escaping (_ resources: inout StartedState.StateResources) async throws(E) -> T,
        wrongState failureBlock: sending @escaping () async throws(E) -> T
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
