//
//  StateMachine Type Conformance Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

extension Int: StateMachineState {
    public var stateID: Int { self }
    public typealias StateResources = Never

    public func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        true
    }
}

@Suite
struct StateMachine_Type_Conformance_Tests {
    @Test
    func defaultState() {
        let sm = StateMachine<Int>(initialState: 1)

        #expect(sm.assertState(is: 1))
    }

    @Test
    func transition() {
        var sm = StateMachine<Int>(initialState: 1)

        #expect(sm.transition(to: 2) == true)

        #expect(sm.assertState(is: 1) == false)
        #expect(sm.assertState(is: 2) == true)
        #expect(sm.assertState(is: 3) == false)
    }
}
