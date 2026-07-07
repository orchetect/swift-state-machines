//
//  StateMachine Enum Tests.swift
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
struct StateMachine_Enum_Tests {
    @Test
    func defaultState() {
        let sm = StateMachine<MyState>(initialState: .one)

        #expect(sm.assertState(is: .one) == true)
    }

    @Test
    func transition() {
        let sm = StateMachine<MyState>(initialState: .one)

        #expect(sm.transition(to: .two) == true)

        #expect(sm.assertState(is: .one) == false)
        #expect(sm.assertState(is: .two) == true)
        #expect(sm.assertState(is: .three) == false)
    }

    @Test
    func withResources() {
        let sm = StateMachine<MyState>(initialState: .one)

        // compiler warning; `Never` resources
        let oneResources: Never? = sm.withResources(for: .one) { resources in
            resources
        } wrongState: {
            nil
        }
        #expect(oneResources == nil)

        // compiler warning; `Never` resources
        let twoResources: Never? = sm.withResources(for: .two) { resources in
            resources
        } wrongState: {
            nil
        }
        #expect(twoResources == nil)
    }
}
