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

// MARK: - Lifecycle

extension StartStopStateMachine {
    @discardableResult
    public func start(
        resources: () -> StartedStateMachineState<StartedResources>.StateResources
    ) -> Bool {
        stateMachine.withLock { stateMachine in
            stateMachine.transition(to: .started()) {
                resources()
            }
        } lockFailure: {
            false
        }
    }

    @_disfavoredOverload @discardableResult
    public func start(
        _ block: () -> Void
    ) -> Bool where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            block()
            return stateMachine.transition(to: .started())
        } lockFailure: {
            false
        }
    }

    @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: consuming ((_ resources: StartedState.StateResources) -> Void)? = nil
    ) -> Bool {
        stateMachine.withLock { stateMachine in
            if let resourcesTeardown {
                stateMachine.withResources(for: .started()) { resources in
                    // clean up resources
                    resourcesTeardown(resources)
                } wrongState: {
                    // ignore
                }
            }

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        } lockFailure: {
            false
        }
    }

    @_disfavoredOverload @discardableResult
    public func stop(
        permanently isPermanent: Bool = false,
        _ block: () -> Void
    ) -> Bool where StartedResources == Never {
        stateMachine.withLock { stateMachine in
            block()

            return isPermanent
                ? stateMachine.transition(to: .stoppedPermanently())
                : stateMachine.transition(to: .stopped())
        } lockFailure: {
            false
        }
    }
}

// MARK: - Started Resources

extension StartStopStateMachine {
    public func withStartedResources<T, E>(
        _ block: (_ resources: inout StartedState.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        try stateMachine.withResources(for: StartedState()) { resources throws(E) -> T in
            try block(&resources)
        } wrongState: { () throws(E) in
            try failureBlock()
        }
    }

    public var startedResources: StartedState.StateResources? {
        stateMachine.resources(for: StartedState())
    }
}

// MARK: - State Asserts

extension StartStopStateMachine {
    public func assertState(is state: StartStopStateID<StartedResources>) -> Bool {
        switch state {
        case .started:
            stateMachine.assertState(is: StartedState())
        case .stopped:
            stateMachine.assertState(is: StoppedState())
        case .stoppedPermanently:
            stateMachine.assertState(is: StoppedPermanentlyState())
        }
    }
}
