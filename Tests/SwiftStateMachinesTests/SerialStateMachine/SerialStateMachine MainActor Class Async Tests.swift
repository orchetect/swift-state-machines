//
//  SerialStateMachine MainActor Class Async Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Synchronization
import Testing

@Suite
struct SerialStateMachine_MainActor_Class_Async_Tests {
    @MainActor
    private final class Foo: Sendable {
        let lifecycle = SerialStateMachine<StartStopStateID>(initialState: .stopped)

        var values: [String] = []

        nonisolated
        init() { }

        nonisolated
        func start() async -> Bool {
            await lifecycle.withLock { stateMachine in
                stateMachine.transition(to: .started)
                let startValue = await startValue()
                await MainActor.run { values.append(startValue) }
                sleep(0.1)
                return true
            } lockFailure: {
                Issue.record("Lock failed")
                return false
            }
        }

        func startValue() async -> String {
            "start"
        }

        nonisolated
        func stop() async -> Bool {
            await lifecycle.withLock { stateMachine in
                stateMachine.transition(to: .stopped)
                let stopValue = await stopValue()
                await MainActor.run { values.append(stopValue) }
                sleep(0.1)
                return true
            } lockFailure: {
                Issue.record("Lock failed")
                return false
            }
        }

        func stopValue() async -> String {
            "stop"
        }
    }

    @Test
    func concurrentStartsAndStopsAsync() async {
        let foo = Foo()

        await withTaskGroup { group in
            group.addTask {
                await foo.start()
            }
        }
        #expect(await foo.values == ["start"])

        await withTaskGroup { group in
            group.addTask {
                await foo.stop()
            }
        }
        #expect(await foo.values == ["start", "stop"])
    }
}
