//
//  StartStopStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// State machine that can start and stop, as well as stop permanently.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public typealias StartStopStateMachine = StateMachine<StartStopStateMachineState>

/// State machine that can start and stop, as well as stop permanently.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public typealias StartStopAsyncStateMachine = AsyncStateMachine<StartStopStateMachineState>
