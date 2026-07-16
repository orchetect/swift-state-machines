//
//  StartStopStateMachine MainActor Class Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing

@Suite
struct StartStopStateMachine_MainActor_Class_Tests {
    @MainActor
    private final class MyObject {
        let lifecycle = StartStopStateMachine<String>()

        @MainActor
        private class SubObject {
            var value: Int = 0

            func setValue(_ value: Int) { self.value = value }

            nonisolated init() { }
        }
        private let subObject = SubObject()

        func getValue() -> Int { subObject.value }

        nonisolated
        init() { }

        @concurrent
        public func start(string: String) async -> StateMachineTransitionResult {
            await lifecycle.start {
                await subObject.setValue(getValue() + 1)
                return string
            }
        }

        @concurrent
        public func stop(permanently: Bool = false) async -> StateMachineTransitionResult {
            lifecycle.stop(permanently: permanently) { resources in
                resources = ""
            }
        }

        @concurrent
        public func read1() async -> String? {
            lifecycle.withStartedResources { resources in
                resources
            } wrongState: {
                nil
            }
        }

        nonisolated
        public func read2() -> String? {
            lifecycle.startedResources
        }
    }

    @Test
    func defaultState() async {
        let foo = MyObject()

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startOnly() async {
        let foo = MyObject()

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(await foo.start(string: "A") == .completed)
        #expect(await foo.start(string: "B") == .skipped) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == "A")
        #expect(foo.read2() == "A")
    }

    @Test
    func stopOnly() async {
        let foo = MyObject()

        #expect(await foo.stop() == .skipped) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startStop() async {
        let foo = MyObject()

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(await foo.start(string: "A") == .completed)
        #expect(await foo.start(string: "B") == .skipped) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == "A")
        #expect(foo.read2() == "A")

        #expect(await foo.stop() == .completed)
        #expect(await foo.stop() == .skipped) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == true)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)
    }

    @Test
    func startStopPermanently() async {
        let foo = MyObject()

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)

        #expect(await foo.start(string: "A") == .completed)
        #expect(await foo.start(string: "B") == .skipped) // already started

        #expect(foo.lifecycle.assertState(is: .started) == true)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == false)

        #expect(await foo.read1() == "A")
        #expect(foo.read2() == "A")

        #expect(await foo.stop(permanently: true) == .completed)
        #expect(await foo.stop(permanently: true) == .skipped) // already stopped

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == true)

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)

        // attempt to restart -- not allowed after permanent stop
        #expect(await foo.start(string: "C") == .failed)

        #expect(foo.lifecycle.assertState(is: .started) == false)
        #expect(foo.lifecycle.assertState(is: .stopped) == false)
        #expect(foo.lifecycle.assertState(is: .stoppedPermanently) == true)

        #expect(await foo.read1() == nil)
        #expect(foo.read2() == nil)
    }
}
