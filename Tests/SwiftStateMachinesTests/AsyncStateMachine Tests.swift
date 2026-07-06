//
//  AsyncStateMachine Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing
import struct Synchronization.Mutex

@Suite
struct AsyncStateMachine_Tests {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func initDefault() /* NOT ASYNC */ {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
        #expect(lifecycle.state == .stopped)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func initDefaultAsync() async {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
        #expect(lifecycle.state == .stopped)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func start() async {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

        actor Receiver {
            var count: Int = 0
            func inc() { count += 1 }
            init() { }
        }

        let receiver = Receiver()

        await lifecycle.withTransition(to: .started) { oldState, context in
            _ = await Task { await receiver.inc() }.value
            #expect(context.isInitial)
        }
        #expect(lifecycle.state == .started)
        #expect(await receiver.count == 1)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func start_NoContext() async {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

        actor Receiver {
            var count: Int = 0
            func inc() { count += 1 }
            init() { }
        }

        let receiver = Receiver()

        await lifecycle.withTransition(to: .started) {
            _ = await Task { await receiver.inc() }.value
        }
        #expect(lifecycle.state == .started)
        #expect(await receiver.count == 1)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func stop() async {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

        actor Receiver {
            var count: Int = 0
            func inc() { count += 1 }
            init() { }
        }

        let receiver = Receiver()

        await lifecycle.withTransition(to: .stopped) { oldState, context in
            _ = await Task { await receiver.inc() }.value
        }
        #expect(lifecycle.state == .stopped)
        #expect(await receiver.count == 0)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func startStop() async {
        final class Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
            nonisolated var closureCallCount: Int {
                get { _closureCallCount.withLock(\.self) }
                set { _closureCallCount.withLock { $0 = newValue } }
            }
            nonisolated private let _closureCallCount: Mutex<Int> = .init(0)
            nonisolated func inc() { closureCallCount += 1 }
            init() { }
        }

        let foo = Foo()

        // start for the first time
        await foo.lifecycle.withTransition(to: .started) { oldState, context in
            foo.inc()
            #expect(context.isInitial)
        }
        #expect(foo.lifecycle.state == .started)
        #expect(foo.closureCallCount == 1)

        // start again
        await foo.lifecycle.withTransition(to: .started) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .started)
        #expect(foo.closureCallCount == 1) // no change

        // stop
        await foo.lifecycle.withTransition(to: .stopped) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .stopped)
        #expect(foo.closureCallCount == 2)

        // stop again
        await foo.lifecycle.withTransition(to: .stopped) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .stopped)
        #expect(foo.closureCallCount == 2) // no change

        // start
        await foo.lifecycle.withTransition(to: .started) { oldState, context in
            foo.inc()
            #expect(!context.isInitial)
        }
        #expect(foo.lifecycle.state == .started)
        #expect(foo.closureCallCount == 3) // no change

        // stop
        await foo.lifecycle.withTransition(to: .stopped) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .stopped)
        #expect(foo.closureCallCount == 4)

        // stop again, but make permanent
        await foo.lifecycle.withTransition(to: .stoppedPermanently) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .stoppedPermanently)
        #expect(foo.closureCallCount == 5)

        // attempt to start
        await foo.lifecycle.withTransition(to: .started) { oldState, context in
            foo.inc()
        }
        #expect(foo.lifecycle.state == .stoppedPermanently) // no change
        #expect(foo.closureCallCount == 5) // no change
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func concurrentStarts() async {
        final class Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
            nonisolated let values: Mutex<[String]> = .init([])
            init() { }
            func start() async {
                await lifecycle.withTransition(to: .started) { oldState, context in
                    self.values.withLock { $0.append("start-\(context.isInitial)") }
                    try? await Task.sleep(seconds: 0.1)
                }
            }
            func stop() async {
                await lifecycle.withTransition(to: .stopped) { oldState, context in
                    self.values.withLock { $0.append("stop") }
                    try? await Task.sleep(seconds: 0.1)
                }
            }
        }

        let foo = Foo()

        await withTaskGroup { group in
            for _ in 0 ..< 100 { // use a large number to check for possible deadlocks
                group.addTask {
                    await foo.start()
                }
            }
            await group.waitForAll()
        }
        #expect(foo.values.withLock(\.self) == ["start-true"])

        await withTaskGroup { group in
            for _ in 0 ..< 100 { // use a large number to check for possible deadlocks
                group.addTask {
                    await foo.stop()
                }
            }
            await group.waitForAll()
        }
        #expect(foo.values.withLock(\.self) == ["start-true", "stop"])
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func withState() async {
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

        await confirmation(expectedCount: 0b1) { confirmation in
            await lifecycle.withState(expecting: [.stopped, .stoppedPermanently]) { context in
                confirmation(count: 0b1)
            } wrongState: { context in
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped)

        await confirmation(expectedCount: 0b10) { confirmation in
            await lifecycle.withState(expecting: .started) { context in
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
        let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

        await confirmation(expectedCount: 0b1) { confirmation in
            await lifecycle.withState(expecting: [.stopped, .stoppedPermanently]) {
                confirmation(count: 0b1)
            } wrongState: {
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped)

        await confirmation(expectedCount: 0b10) { confirmation in
            await lifecycle.withState(expecting: .started) {
                confirmation(count: 0b1)
            } wrongState: {
                confirmation(count: 0b10)
            }
        }
        #expect(lifecycle.state == .stopped) // no change
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func dummyClass() async {
        final class Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)

            var values: [String] {
                get { _values.withLock(\.self) }
                set { _values.withLock { $0 = newValue } }
            }
            private let _values: Mutex<[String]> = .init([])

            func add(value: String) { values.append(value) }

            init() { }

            func foo() async {
                await lifecycle.withTransition(to: .started) { [self] oldState, context in
                    _ = values
                    add(value: "start-\(context.isInitial)")
                    try? await Task.sleep(seconds: 0.1)
                }
                await lifecycle.withState(expecting: .started) { [self] context in
                    add(value: "withState-\(context.isInitial)")
                } wrongState: { context in
                    // empty
                }
            }
        }

        let foo = Foo()

        await foo.foo()
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func dummyActor() async {
        final actor Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
            var values: [String] = []
            func add(value: String) { values.append(value) }

            init() { }

            func foo() async {
                await lifecycle.withTransition(to: .started) { [self] oldState, context in
                    _ = await values
                    await add(value: "start-\(context.isInitial)")
                    try? await Task.sleep(seconds: 0.1)
                }
                await lifecycle.withState(expecting: .started) { [self] context in
                    await add(value: "withState-\(context.isInitial)")
                } wrongState: { context in
                    // empty
                }
            }
        }

        let foo = Foo()

        await foo.foo()
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func mainActorClass() async {
        @MainActor final class Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
            var values: [String] = []
            func add(value: String) { values.append(value) }

            nonisolated init() { }

            func foo() async {
                await lifecycle.withTransition(to: .started) { [self] oldState, context in
                    _ = await values
                    await add(value: "start-\(context.isInitial)")
                    try? await Task.sleep(seconds: 0.1)
                }
                await lifecycle.withState(expecting: .started) { [self] context in
                    await add(value: "withState-\(context.isInitial)")
                } wrongState: { [self] context in
                    await add(value: "withState-wrong-\(context.isInitial)")
                }
            }
        }

        let foo = Foo()

        await foo.foo()
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func mainActorProperty() async {
        final class Foo: Sendable {
            let lifecycle = AsyncStateMachine<StartStopStateMachineState>(initialState: .stopped)
            @MainActor var values: [String] = []
            func add(value: String) async { await MainActor.run { values.append(value) } }

            nonisolated init() { }

            func foo() async {
                await lifecycle.withTransition(to: .started) { [self] oldState, context in
                    _ = await values
                    await add(value: "start")
                    try? await Task.sleep(seconds: 0.1)
                }
                await lifecycle.withState(expecting: .started) { [self] context in
                    await add(value: "withState-\(context.isInitial)")
                } wrongState: { [self] context in
                    await add(value: "withState-wrong-\(context.isInitial)")
                }
            }
        }

        let foo = Foo()

        await foo.foo()
    }
}
