//
//  Collector Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftStateMachines
import Testing
import TestingExtensions

@Suite
struct Collector_Tests {
    @Test(arguments: 0 ..< 10)
    func noInitialHandler(iteration: Int) async {
        let receiver = Receiver<Int>()

        let collector = Collector<Int>()

        collector.publish(1)
        collector.publish(2)
        collector.publish(3)

        // check internal state
        await wait(expect: { await collector.valuesBacklog == [1, 2, 3] }, timeout: 10.0)

        // setting the handler causes the values backlog to be released
        collector.setReceiver { value in
            Task { @TestActor in await receiver.add(value) }
        }

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    @Test(arguments: 0 ..< 10)
    func withInitialHandler(iteration: Int) async {
        let receiver = Receiver<Int>()

        let collector = Collector<Int> { value in
            Task { @TestActor in await receiver.add(value) }
        }

        collector.publish(1)
        collector.publish(2)
        collector.publish(3)

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    /// Test that existential Sendable types such as closures work.
    @Test
    func sendableClosureValue() async {
        let receiver = Receiver<Int>()

        let collector = Collector<@Sendable () -> Int> { value in
            Task { @TestActor in await receiver.add(value()) }
        }

        collector.publish({ 1 })
        collector.publish({ 2 })
        collector.publish({ 3 })

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    #if !GITHUB_ACTIONS
    /// This tests the ordering of values dispatch.
    /// Also check that more than one instance are independent.
    ///
    /// This test requires precise timing measurement. As such is exempted from running on CI pipelines.
    @Test
    func orderingAndConcurrentNotifiers() async {
        func runTest() async {
            let receiver = Receiver<Int>()

            let collector = Collector<Int> { value in
                sleep(TimeInterval(value))
                Task { @TestActor in await receiver.add(value) }
            }

            let inTime = Date()
            collector.publish(3)
            collector.publish(2)
            collector.publish(1)

            // check ordering
            await wait(expect: { await receiver.items == [3, 2, 1] }, timeout: 10.0)
            let outTime = Date()

            // sends should run serially
            #expect(outTime.timeIntervalSince(inTime) >= 6.0)
        }

        let inTime = Date()
        async let a = runTest()
        async let b = runTest()
        _ = await (a, b)
        let outTime = Date()

        // both runs should run concurrently
        #expect(outTime.timeIntervalSince(inTime) >= 6.0)
        #expect(outTime.timeIntervalSince(inTime) < 12.0)
    }
    #endif
}
