//
//  SerialTaskQueue.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// A serial `Task` queue that executes Swift Concurrency tasks in FIFO order.
///
/// Tasks may be enqueued asynchronously or waited upon. Regardless, all tasks are
/// executed in serial order and each task is completed fully before the next task is
/// executed.
public final class SerialTaskQueue {
    private typealias Stream = AsyncStream<() async throws -> Void>

    private var task: Task<Void, any Error>? {
        get { lock.withLock { _task } }
        set { lock.withLock { _task = newValue} }
    }
    nonisolated(unsafe)
    private var _task: Task<Void, any Error>?

    private var continuation: Stream.Continuation? {
        get { lock.withLock { _continuation } }
        set { lock.withLock { _continuation = newValue} }
    }
    nonisolated(unsafe)
    private var _continuation: Stream.Continuation?

    nonisolated
    private let lock = NSLock()

    /// Boolean value determining queue behavior when the class deinits.
    ///
    /// When `true`, if an operation is in-progress it will be cancelled and any remaining operations
    /// enqueued will be discarded.
    ///
    /// When `false, all enqueued operations are allowed to complete in serial order in the background.
    nonisolated
    public let isCancelledOnDeinit: Bool

    /// - Parameters:
    ///   - cancelOnDeinit: When `true`, if an operation is in-progress it will be cancelled and
    ///   any remaining operations enqueued will be discarded. When `false, all enqueued operations are
    ///   allowed to complete in serial order in the background.
    public init(cancelOnDeinit: Bool = true) {
        self.isCancelledOnDeinit = cancelOnDeinit

        let stream = AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
        task = Task { [weak self, task] in
            for await operation in stream {
                try await operation()
            }
            task?.cancel()
            self?.cleanup()
        }
    }

    deinit {
        if isCancelledOnDeinit {
            cancel()
        }
        continuation = nil
    }
}

extension SerialTaskQueue: Sendable { }

// MARK: - Lifecycle

extension SerialTaskQueue {
    /// Manually cancel the task queue.
    /// If an operation is in-progress it will be cancelled and any remaining operations enqueued will
    /// be discarded.
    ///
    /// Once cancelled, the queue cannot be restarted.
    ///
    /// > Note:
    /// >
    /// > This method is automatically called on class deinit if ``isCancelledOnDeinit`` is `true`.
    public func cancel() {
        task?.cancel()
        continuation?.finish()
        cleanup()
    }

    private func cleanup() {
        task = nil
        continuation = nil
    }
}

// MARK: - Queue

extension SerialTaskQueue {
    /// Enqueue an operation and return immediately.
    ///
    /// The operation is started asynchronously immediately if the queue is empty, otherwise it is
    /// enqueued and executed once the current operation(s) are finished.
    ///
    /// > Note:
    /// >
    /// > This method is safe to call recursively as all newly-enqueued operations are asynchronously
    /// > appended to the end of the queue.
    public func enqueue(
        _ operation: sending @escaping () async throws -> Void
    ) {
        continuation?.yield(operation)
    }

    /// Enqueue an operation and wait for its completion, optionally returning a value.
    ///
    /// The operation is started asynchronously immediately if the queue is empty, otherwise it is
    /// enqueued and executed once the current operation(s) are finished.
    ///
    /// > Note:
    /// >
    /// > Use care when calling this method, as it can lead to a queue deadlocks if nested calls are
    /// > inadvertently made to it.
    public func enqueueAndWait<T>(
        _ operation: @Sendable @escaping () async throws -> T
    ) async rethrows -> sending T {
        await withCheckedContinuation { localContinuation in
            continuation?.yield {
                let value = try await operation()
                localContinuation.resume(with: .success(value))
            }
        }
    }
}
