//
//  StateMachine StartStop Static Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

@Suite
struct StateMachine_StartStop_Static_Tests {
    @Test
    func hasResources() {
        var sm = StateMachine(initialState: .started(), resources: 1)

        // assert
        #expect(sm.assertState(is: .started()) == true)
        #expect(sm.assertState(is: .started) == true)
        #expect(sm.assertState(is: .stopped) == false)
        #expect(sm.assertState(is: .stoppedPermanently) == false)

        // resources
        #expect(sm.resources(for: .started()) == 1)
        #expect(sm.resources(for: .stopped()) == nil) // compiler warning; `Never` resources
        #expect(sm.resources(for: .stoppedPermanently()) == nil) // compiler warning; `Never` resources

        // with resources
        do {
            let r = sm.withResources(for: .started()) { resources in
                resources
            } wrongState: {
                nil
            }
            #expect(r == 1)
        }
        do {
            // compiler warning; `Never` resources
            let r: Never? = sm.withResources(for: .stopped()) { resources in
                resources
            } wrongState: {
                nil
            }
            #expect(r == nil)
        }

        do {
            // compiler warning; `Never` resources
            let r: Never? = sm.withResources(for: .stoppedPermanently()) { resources in
                resources
            } wrongState: {
                nil
            }
            #expect(r == nil)
        }
    }

    @Test
    func transitions() {
        let sm = StateMachine(initialState: .started(), resources: 1)

        // stop
        #expect(sm.transition(to: .stopped()) == true)
        #expect(sm.assertState(is: .stopped) == true)
        #expect(sm.transition(to: .stopped()) == false) // already stopped

        // start
        #expect(sm.transition(to: .started()) { 2 } == true)
        #expect(sm.assertState(is: .started) == true)
        #expect(sm.resources(for: .started()) == 2)
        #expect(sm.transition(to: .started()) { 3 } == false) // already started
        #expect(sm.resources(for: .started()) == 2) // unchanged

        // stop
        #expect(sm.transition(to: .stopped()) == true)
        #expect(sm.assertState(is: .stopped) == true)

        // stop permanently
        #expect(sm.transition(to: .stoppedPermanently()) == true)
        #expect(sm.assertState(is: .stoppedPermanently) == true)

        // attempt to start; fails
        #expect(sm.transition(to: .started()) { 2 } == false) // not allowed; stopped permanently
        #expect(sm.assertState(is: .stoppedPermanently) == true) // unchanged

        // attempt to stop non-permanently; fails
        #expect(sm.transition(to: .stopped()) == false) // not allowed; stopped permanently
        #expect(sm.assertState(is: .stoppedPermanently) == true) // unchanged
    }

    @Test func noResources() {
        // since no resources type is declared, `Never` is defaulted and we can use the non-Generics static constructor
        let sm = StateMachine(initialState: .started)
        #expect(sm.assertState(is: .started) == true)
    }
}
