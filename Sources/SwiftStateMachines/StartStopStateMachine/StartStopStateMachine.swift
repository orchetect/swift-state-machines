//
//  StartStopStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StartStopStateMachine<StartedResources: Sendable> {
    public typealias StartedState = StartedStateMachineState<StartedResources>
    public typealias StoppedState = StoppedStateMachineState<StartedResources>
    public typealias StoppedPermanentlyState = StoppedPermanentlyStateMachineState<StartedResources>

    var stateMachine = StateMachine<StartStopStateID>(initialState: StoppedState())

    public init() { }
}

// MARK: - Lifecycle

extension StartStopStateMachine {
    public mutating func start(
        resources: () -> StartedStateMachineState<StartedResources>.StateResources
    ) -> Bool {
        stateMachine.transition(to: StartedStateMachineState<StartedResources>()) {
            resources()
        }
    }

    public mutating func stop(
        permanently isPermanent: Bool = false,
        resourcesTeardown: ((_ resources: StartedState.StateResources) -> Void)? = nil
    ) -> Bool {
        if let resourcesTeardown {
            stateMachine.withResources(for: StartedState()) { resources in
                // clean up resources
                resourcesTeardown(resources)
            } wrongState: {
                // ignore
            }
        }

        return isPermanent
            ? stateMachine.transition(to: StoppedPermanentlyState())
            : stateMachine.transition(to: StoppedState())
    }
}

// MARK: - Started Resources

extension StartStopStateMachine {
    public mutating func withStartedResources<T, E>(
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
