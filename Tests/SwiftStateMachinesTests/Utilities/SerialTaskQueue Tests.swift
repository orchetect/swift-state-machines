//
//  SerialTaskQueue Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftStateMachines
import Testing
import TestingExtensions

@Suite
struct SerialTaskQueue_Tests {
    @Test
    func ordering() async {
        let receiver = Receiver<Int>()

        let taskQueue = SerialTaskQueue()
        taskQueue.async {
            try? await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue.async {
            try? await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue.async {
            receiver.add(3)
        }

        await wait(expect: { receiver.items == [1, 2, 3] }, timeout: 20.0)

        // restate expectation using Swift Testing native macros for more detailed logging
        #expect(receiver.items == [1, 2, 3])
    }

    @Test
    func returnValues() async throws {
        let receiver = Receiver<Int>()

        let taskQueue = SerialTaskQueue()
        let value1 = try await taskQueue.sync {
            try? await Task.sleep(seconds: 1.0)
            receiver.add(1)
            return 1
        }
        let value2 = try await taskQueue.sync {
            try? await Task.sleep(seconds: 0.5)
            receiver.add(2)
            return 2
        }
        let value3 = try await taskQueue.sync {
            receiver.add(3)
            return 3
        }

        #expect(receiver.items == [1, 2, 3])

        #expect(value1 == 1)
        #expect(value2 == 2)
        #expect(value3 == 3)
    }

    @Test
    func deinit_cancelOnDeinit_withoutChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue!.async {
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue!.async {
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue!.async {
            receiver.add(3)
        }

        // deinit the queue
        taskQueue = nil

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(receiver.items == [])
    }

    @Test
    func deinit_cancelOnDeinit_withChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            receiver.add(3)
        }

        // deinit the queue
        taskQueue = nil

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(receiver.items == [])
    }

    @Test
    func deinit_noCancelOnDeinit_withoutChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: false)
        taskQueue!.async {
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue!.async {
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue!.async {
            receiver.add(3)
        }

        // deinit the queue
        taskQueue = nil

        await wait(expect: { receiver.items == [1, 2, 3] }, timeout: 20.0)

        // restate expectation using Swift Testing native macros for more detailed logging
        #expect(receiver.items == [1, 2, 3])
    }

    @Test
    func deinit_noCancelOnDeinit_withChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: false)
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue!.async {
            guard !Task.isCancelled else { return }
            receiver.add(3)
        }

        // deinit the queue
        taskQueue = nil

        await wait(expect: { receiver.items == [1, 2, 3] }, timeout: 20.0)

        // restate expectation using Swift Testing native macros for more detailed logging
        #expect(receiver.items == [1, 2, 3])
    }

    @Test
    func cancel_withoutChecks() async throws {
        let receiver = Receiver<Int>()

        let taskQueue = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue.async {
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue.async {
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue.async {
            receiver.add(3)
        }

        // cancel the queue manually
        taskQueue.cancel()

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(receiver.items == [])
    }

    @Test
    func cancel_withChecks() async throws {
        let receiver = Receiver<Int>()

        let taskQueue = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 1.0)
            receiver.add(1)
        }
        taskQueue.async {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 0.5)
            receiver.add(2)
        }
        taskQueue.async {
            guard !Task.isCancelled else { return }
            receiver.add(3)
        }

        // cancel the queue manually
        taskQueue.cancel()

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(receiver.items == [])
    }

    /// Ensure that errors thrown from `.sync { }` body are rethrown.
    @Test
    func syncThrowError() async throws {
        let taskQueue = SerialTaskQueue(cancelOnDeinit: false)

        struct FooError: Error, Equatable, Hashable, Sendable { }

        await #expect(throws: FooError.self) {
            _ = try await taskQueue.sync { throw FooError() }
        }
    }

    /// `.sync { }` requires `cancelOnDeinit` to be `false` otherwise it always throws.
    @Test
    func syncWithCancelOnDeinit() async throws {
        let taskQueue = SerialTaskQueue(cancelOnDeinit: true)

        await #expect(throws: CancellationError.self) {
            _ = try await taskQueue.sync { 1 }
        }
    }

    // WARNING: This test will cause a guaranteed deadlock.
    // It's not trivial to implement deadlock detection or a timeout so we can't test deadlocks
    // without deadlocking the actual test itself.
    // @Test
    // func deadlock() async throws {
    //     let taskQueue = SerialTaskQueue()
    //     print("call 1")
    //     try await taskQueue.sync {
    //         print("call 2")
    //         try await taskQueue.sync { }
    //         print("call 2 done")
    //     }
    //     print("call 1 done")
    // }
}
