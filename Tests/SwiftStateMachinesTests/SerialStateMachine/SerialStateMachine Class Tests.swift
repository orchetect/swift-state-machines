//
//  SerialStateMachine Class Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Synchronization
import Testing

@Suite
struct SerialStateMachine_Class_Tests {
    private final class Foo: Sendable {
        let lifecycle = SerialStateMachine<StartStopStateID>(initialState: .stopped)

        @MainActor var values: [String] = []

        init() { }

        func start() -> Bool {
            lifecycle.withLock { stateMachine in
                stateMachine.transition(to: .started)
                Task { @MainActor in values.append("start") }
                sleep(0.1)
                return true
            } lockFailure: {
                Issue.record("Lock failed")
                return false
            }
        }

        func stop() -> Bool {
            lifecycle.withLock { stateMachine in
                stateMachine.transition(to: .stopped)
                Task { @MainActor in values.append("stop") }
                sleep(0.1)
                return true
            } lockFailure: {
                Issue.record("Lock failed")
                return false
            }
        }
    }

    @Test
    func concurrentStartsAndStopsAsync() async {
        let foo = Foo()

        await withTaskGroup { group in
            group.addTask {
                foo.start()
            }
        }
        #expect(await foo.values == ["start"])

        await withTaskGroup { group in
            group.addTask {
                foo.stop()
            }
        }
        #expect(await foo.values == ["start", "stop"])
    }
}
