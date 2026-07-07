//
//  StartStopStateMachine Class Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

@Suite
struct StartStopStateMachine_Class_Tests {
    private class MyObject {
        var lifecycle = StartStopStateMachine<String>()

        init() { }

        public func start(string: String) -> Bool {
            lifecycle.start {
                string
            }
        }

        public func stop(permanently: Bool = false) -> Bool {
            lifecycle.stop(permanently: permanently, resourcesTeardown: { _ in })
        }

        public func read1() -> String? {
            lifecycle.withStartedResources { resources in
                resources
            } wrongState: {
                nil
            }
        }

        public func read2() -> String? {
            lifecycle.startedResources
        }
    }

    @Test
    func defaultState() {
        let foo = MyObject()

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startOnly() {
        let foo = MyObject()

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(foo.start(string: "A"))
        #expect(!foo.start(string: "B")) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == "A")
        #expect(foo.read2() == "A")
    }

    @Test
    func stopOnly() {
        let foo = MyObject()

        #expect(foo.stop() == false) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startStop() {
        let foo = MyObject()

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(foo.start(string: "A"))
        #expect(!foo.start(string: "B")) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == "A")
        #expect(foo.read2() == "A")

        #expect(foo.stop())
        #expect(!foo.stop()) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startStopPermanently() {
        let foo = MyObject()

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(foo.start(string: "A"))
        #expect(!foo.start(string: "B")) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(foo.read1() == "A")
        #expect(foo.read2() == "A")

        #expect(foo.stop(permanently: true) == true)
        #expect(foo.stop(permanently: true) == false) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == true)

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)

        // attempt to restart -- not allowed after permanent stop
        #expect(foo.start(string: "C") == false)

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == true)

        #expect(foo.read1() == nil)
        #expect(foo.read2() == nil)
    }
}
