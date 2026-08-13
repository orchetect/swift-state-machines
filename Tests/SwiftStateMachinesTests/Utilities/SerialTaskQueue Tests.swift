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
        taskQueue.enqueue {
            try? await Task.sleep(seconds: 1.0)
            await receiver.add(1)
        }
        taskQueue.enqueue {
            try? await Task.sleep(seconds: 0.5)
            await receiver.add(2)
        }
        taskQueue.enqueue {
            await receiver.add(3)
        }

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    @Test
    func returnValues() async {
        let receiver = Receiver<Int>()

        let taskQueue = SerialTaskQueue()
        let value1 = await taskQueue.enqueueAndWait {
            try? await Task.sleep(seconds: 1.0)
            await receiver.add(1)
            return 1
        }
        let value2 = await taskQueue.enqueueAndWait {
            try? await Task.sleep(seconds: 0.5)
            await receiver.add(2)
            return 2
        }
        let value3 = await taskQueue.enqueueAndWait {
            await receiver.add(3)
            return 3
        }

        #expect(await receiver.items == [1, 2, 3])

        #expect(value1 == 1)
        #expect(value2 == 2)
        #expect(value3 == 3)
    }

    @Test
    func deinitNonCancellingWithoutChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue!.enqueue {
            try await Task.sleep(seconds: 1.0)
            await receiver.add(1)
        }
        taskQueue!.enqueue {
            try await Task.sleep(seconds: 0.5)
            await receiver.add(2)
        }
        taskQueue!.enqueue {
            await receiver.add(3)
        }

        // deinit the queue.
        taskQueue = nil

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(await receiver.items.isEmpty)
    }

    @Test
    func deinitNonCancellingWithChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: true)
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 1.0)
            await receiver.add(1)
        }
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 0.5)
            await receiver.add(2)
        }
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            await receiver.add(3)
        }

        // deinit the queue.
        taskQueue = nil

        // wait a minimum duration in order to catch any potentially non-cancelled enqueued tasks
        // if they are not successfully cancelled
        try await Task.sleep(seconds: 2.0)
        #expect(await receiver.items.isEmpty)
    }

    @Test
    func deinitCancellingWithoutChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: false)
        taskQueue!.enqueue {
            try await Task.sleep(seconds: 1.0)
            await receiver.add(1)
        }
        taskQueue!.enqueue {
            try await Task.sleep(seconds: 0.5)
            await receiver.add(2)
        }
        taskQueue!.enqueue {
            await receiver.add(3)
        }

        // deinit the queue.
        taskQueue = nil

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    @Test
    func deinitCancellingWithChecks() async throws {
        let receiver = Receiver<Int>()

        var taskQueue: SerialTaskQueue? = SerialTaskQueue(cancelOnDeinit: false)
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 1.0)
            await receiver.add(1)
        }
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            try await Task.sleep(seconds: 0.5)
            await receiver.add(2)
        }
        taskQueue!.enqueue {
            guard !Task.isCancelled else { return }
            await receiver.add(3)
        }

        // deinit the queue.
        taskQueue = nil

        await wait(expect: { await receiver.items == [1, 2, 3] }, timeout: 10.0)
    }

    @Test
    func deadlock() async throws {
        let taskQueue = SerialTaskQueue()
        await taskQueue.enqueueAndWait {
            await taskQueue.enqueueAndWait { }
        }
    }
}
