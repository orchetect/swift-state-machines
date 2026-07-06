//
//  StateMachineState Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

@Suite
struct StateMachineState_Tests {
    @Test
    func stateMachineState() {
        #expect(StartStopStateMachineState.started == .started)
        #expect(.started == StartStopStateMachineState.started)

        #expect(StartStopStateMachineState.started != .stopped)
        #expect(.stopped != StartStopStateMachineState.started)
    }

    @Test
    func transitionableStateMachineState() {
        #expect(TransitionableStateMachineState<StartStopStateMachineState>.state(.started) == .state(.started))
        #expect(.state(.started) == TransitionableStateMachineState<StartStopStateMachineState>.state(.started))

        #expect(TransitionableStateMachineState<StartStopStateMachineState>.state(.started) != .state(.stopped))
        #expect(.state(.stopped) != TransitionableStateMachineState<StartStopStateMachineState>.state(.started))
    }

    @Test
    func transitionableStateMachineState_and_stateMachineState() {
        #expect(TransitionableStateMachineState<StartStopStateMachineState>.state(.started) == .started)
        #expect(.started == TransitionableStateMachineState<StartStopStateMachineState>.state(.started))

        #expect(TransitionableStateMachineState<StartStopStateMachineState>.state(.started) != .stopped)
        #expect(.stopped != TransitionableStateMachineState<StartStopStateMachineState>.state(.started))
    }
}
