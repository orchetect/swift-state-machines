//
//  StartedStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StartedStateMachineState<StartedResources: Sendable>: StateMachineState {
    public let stateID: StartStopStateID<StartedResources> = .started

    public typealias StateResources = StartedResources

    public init() { }

    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        switch newState.stateID {
        case .started: false
        case .stopped: true
        case .stoppedPermanently: true
        }
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == StartedStateMachineState<Sendable> {
    public static func started<T: Sendable>(_ startedResourcesType: T.Type = T.self) -> StartedStateMachineState<T> {
        StartedStateMachineState()
    }
}

extension StateMachineState where Self == StartedStateMachineState<Never> {
    public static var started: Self {
        Self()
    }
}
