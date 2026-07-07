//
//  StoppedPermanentlyStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StoppedPermanentlyStateMachineState<StartedResources>: StateMachineState {
    public let stateID: StartStopStateID<StartedResources> = .stoppedPermanently

    public typealias StateResources = Never

    public init() { }

    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        false
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == StoppedPermanentlyStateMachineState<Sendable> {
    public static func stoppedPermanently<T: Sendable>(_ startedResourcesType: T.Type = T.self) -> StoppedPermanentlyStateMachineState<T> {
        StoppedPermanentlyStateMachineState()
    }
}

extension StateMachineState where Self == StoppedPermanentlyStateMachineState<Never> {
    public static var stoppedPermanently: Self {
        Self()
    }
}
