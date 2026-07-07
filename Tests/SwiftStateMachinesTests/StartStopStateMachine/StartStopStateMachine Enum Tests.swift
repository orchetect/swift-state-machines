//
//  StartStopStateMachine Enum Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

fileprivate enum MyState: String, Sendable {
    case one
    case two
    case three
}

extension MyState: StateMachineState {
    var stateID: MyState { self }

    typealias StateResources = Never

    func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        true
    }
}

@Suite
struct StartStopStateMachine_Enum_Tests {
    @Test
    func defaultState() {
        let sm = StateMachine<MyState>(initialState: .one)

        #expect(sm.assertState(is: .one))
    }

    @Test
    func transition() {
        var sm = StateMachine<MyState>(initialState: .one)

        #expect(sm.transition(to: .two) == true)

        #expect(sm.assertState(is: .one) == false)
        #expect(sm.assertState(is: .two) == true)
        #expect(sm.assertState(is: .three) == false)
    }
}
