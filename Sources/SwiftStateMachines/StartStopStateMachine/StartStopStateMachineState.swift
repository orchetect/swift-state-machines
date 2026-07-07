//
//  StartStopStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StartStopStateMachineState<StartedResources>: StateMachineState where StateID == StartStopStateID<StartedResources> {
    associatedtype StartedResources: Sendable
}
