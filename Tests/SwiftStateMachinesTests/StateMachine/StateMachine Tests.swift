//
//  StateMachine Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing
import struct Synchronization.Mutex

@Suite
struct StateMachine_Tests {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func initDefault() /* NOT ASYNC */{
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
        #expect(lifecycle.state == .stopped)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func initDefaultAsync() async {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
        #expect(lifecycle.state == .stopped)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func start() /* NOT ASYNC */ {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
        var closureCallCount = 0

        lifecycle.withTransition(to: .started) { oldState, context in
            closureCallCount += 1
            #expect(context.isInitial)
        }
        #expect(lifecycle.state == .started)
        #expect(closureCallCount == 1)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func stop() /* NOT ASYNC */ {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
        var closureCallCount = 0

        lifecycle.withTransition(to: .stopped) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stopped)
        #expect(closureCallCount == 0)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func startStop() /* NOT ASYNC */ {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
        var closureCallCount = 0

        // start for the first time
        lifecycle.withTransition(to: .started) { oldState, context in
            closureCallCount += 1
            #expect(context.isInitial)
        }
        #expect(lifecycle.state == .started)
        #expect(closureCallCount == 1)

        // start again
        lifecycle.withTransition(to: .started) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .started)
        #expect(closureCallCount == 1) // no change

        // stop
        lifecycle.withTransition(to: .stopped) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stopped)
        #expect(closureCallCount == 2)

        // stop again
        lifecycle.withTransition(to: .stopped) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stopped)
        #expect(closureCallCount == 2) // no change

        // start
        lifecycle.withTransition(to: .started) { oldState, context in
            closureCallCount += 1
            #expect(!context.isInitial)
        }
        #expect(lifecycle.state == .started)
        #expect(closureCallCount == 3) // no change

        // stop
        lifecycle.withTransition(to: .stopped) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stopped)
        #expect(closureCallCount == 4)

        // stop again, but make permanent
        lifecycle.withTransition(to: .stoppedPermanently) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stoppedPermanently)
        #expect(closureCallCount == 5)

        // attempt to start
        lifecycle.withTransition(to: .started) { oldState, context in
            closureCallCount += 1
        }
        #expect(lifecycle.state == .stoppedPermanently) // no change
        #expect(closureCallCount == 5) // no change
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func concurrentStartsAndStops() async {
        final class Foo: Sendable {
            let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
            let values: Mutex<[String]> = .init([])
            init() { }
            func start() {
                lifecycle.withTransition(to: .started) { oldState, context in
                    values.withLock { $0.append("start-\(context.isInitial)") }
                    usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                }
            }
            func stop() {
                lifecycle.withTransition(to: .stopped) { oldState, context in
                    values.withLock { $0.append("stop") }
                    usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                }
            }
        }

        let foo = Foo()

        await withTaskGroup { group in
            for _ in 0 ..< 100 { // use a large number to check for possible deadlocks
                group.addTask {
                    foo.start()
                }
            }
            await group.waitForAll()
        }
        #expect(foo.values.withLock(\.self) == ["start-true"])

        await withTaskGroup { group in
            for _ in 0 ..< 100 { // use a large number to check for possible deadlocks
                group.addTask {
                    foo.stop()
                }
            }
            await group.waitForAll()
        }
        #expect(foo.values.withLock(\.self) == ["start-true", "stop"])
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func concurrentStartsAndStopsAsync() async {
        final class Foo: Sendable {
            let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
            @MainActor var values: [String] = []
            init() { }
            func start() async {
                await lifecycle.withTransition(to: .started) { oldState, context in
                    await MainActor.run { values.append("start-\(context.isInitial)") }
                    usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                }
            }
            func stop() async {
                await lifecycle.withTransition(to: .stopped) { oldState, context in
                    await MainActor.run { values.append("stop") }
                    usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                }
            }
        }

        let foo = Foo()

        await withTaskGroup { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    await foo.start()
                }
            }
            await group.waitForAll()
        }
        #expect(await foo.values == ["start-true"])

        await withTaskGroup { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    await foo.stop()
                }
            }
            await group.waitForAll()
        }
        #expect(await foo.values == ["start-true", "stop"])
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func withState() async {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)

        await confirmation(expectedCount: 0b1) { confirmation in
            lifecycle.withState(expecting: [.stopped, .stoppedPermanently]) { context in
                confirmation(count: 0b1)
            } wrongState: { context in
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped)

        await confirmation(expectedCount: 0b10) { confirmation in
            lifecycle.withState(expecting: .started) { context in
                confirmation(count: 0b1)
            } wrongState: { context in
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped) // no change
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func withState_NoContext() async {
        let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)

        await confirmation(expectedCount: 0b1) { confirmation in
            lifecycle.withState(expecting: [.stopped, .stoppedPermanently]) {
                confirmation(count: 0b1)
            } wrongState: {
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped)

        await confirmation(expectedCount: 0b10) { confirmation in
            lifecycle.withState(expecting: .started) {
                confirmation(count: 0b1)
            } wrongState: {
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped) // no change
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func withStateAsync() async {
        final class Foo: Sendable {
            let lifecycle = StateMachine<StartStopStateMachineState>(initialState: .stopped)
            @MainActor var values: [String] = []
            init() { }
        }

        let foo = Foo()

        await confirmation(expectedCount: 0b1) { confirmation in
            await foo.lifecycle.withState(expecting: [.stopped, .stoppedPermanently]) { context in
                _ = await foo.values // just to force async overload of method
                confirmation(count: 0b1)
            } wrongState: { context in
                confirmation(count: 0b10)
            }
        }
        #expect(foo.lifecycle.state == .stopped)

        await confirmation(expectedCount: 0b10) { confirmation in
            await foo.lifecycle.withState(expecting: .started) { context in
                _ = await foo.values // just to force async overload of method
                confirmation(count: 0b1)
            } wrongState: { context in
                confirmation(count: 0b10)
            }
        }
        #expect(foo.lifecycle.state == .stopped) // no change
    }
}
