//
//  StoppedPermanentlyStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StoppedPermanentlyStateMachineState<StartedResources>: StartStopStateMachineState<StartedResources> {
    public let stateID: StartStopStateID<StartedResources> = .stoppedPermanently

    public typealias StateResources = Never

    public init() { }

    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        false
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == StoppedPermanentlyStateMachineState<any Any> {
    public static var stoppedPermanently: Self {
        Self()
    }
}

extension StateMachineState where Self == StoppedPermanentlyStateMachineState<Never> {
    public static var stoppedPermanently: Self {
        Self()
    }
}
