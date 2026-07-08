//
//  StateMachineActor Class Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Synchronization
import Testing

@Suite
struct StateMachineActor_Class_Tests {
    private final class Foo: Sendable {
        let lifecycle = StateMachineActor<StartStopStateID>(initialState: .stopped)

        @MainActor var values: [String] = []

        init() { }

        func start() async -> Bool {
            await lifecycle.withActor { stateMachine in
                lifecycle.transition(to: .started)
                Task { @MainActor in values.append("start") }
                usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                return true
            }
        }

        func stop() async -> Bool {
            await lifecycle.withActor { stateMachine in
                stateMachine.transition(to: .stopped)
                Task { @MainActor in values.append("stop") }
                usleep(UInt32(0.1 * Double(USEC_PER_SEC)))
                return true
            }
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
