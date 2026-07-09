//
//  StateMachine Sendable Class Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

fileprivate final class Foo: Sendable {
    let lifecycle = SendableStateMachine(initialState: FooState(), resources: 1)

    init() { }
}

struct FooState: StateMachineState {
    typealias StateResources = NSNumber

    typealias StateID = String
    let stateID: String = "foo"

    init() { }

    func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
        false
    }
}

@Suite
struct StateMachine_Sendable_Class_Tests {
    @Test
    func defaultState() {
        let foo = Foo()

        #expect(foo.lifecycle.assertState(is: FooState()) == true)
        #expect(foo.lifecycle.resources(for: FooState()) == 1)
    }
}
