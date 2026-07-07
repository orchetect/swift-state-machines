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
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    private final class Foo: Sendable {
        let lifecycle = SerialStateMachine<StartStopStateID>(initialState: .stopped)

        @MainActor var values: [String] = []

        init() { }

        func start() -> Bool {
            lifecycle.withLock { stateMachine in
                stateMachine.transition(to: .started)
                Task { @MainActor in values.append("start") }
                usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
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
                usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                return true
            } lockFailure: {
                Issue.record("Lock failed")
                return false
            }
        }
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
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
