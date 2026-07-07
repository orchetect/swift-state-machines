//
//  StoppedStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StoppedStateMachineState<StartedResources>: StateMachineState {
    public let stateID: StartStopStateID<StartedResources> = .stopped

    public typealias StateResources = Never

    public init() { }

    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        switch newState.stateID {
        case .started: true
        case .stopped: false
        case .stoppedPermanently: true
        }
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == StoppedStateMachineState<Sendable> {
    public static func stopped<T: Sendable>(_ startedResourcesType: T.Type = T.self) -> StoppedStateMachineState<T> {
        StoppedStateMachineState()
    }
}

extension StateMachineState where Self == StoppedStateMachineState<Never> {
    public static var stopped: Self {
        Self()
    }
}
