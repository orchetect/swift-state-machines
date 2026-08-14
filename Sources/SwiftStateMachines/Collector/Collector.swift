//
//  Collector.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// An object which publishes values to a receiver sequentially.
/// Published values are collected as a backlog until a receiver is assigned.
///
/// Once a receiver is assigned, the backlog of collected values are passed to the receiver.
/// After that, all values are directly passed to the receiver without being collected.
public actor Collector<T: Sendable> {
    public typealias Receiver = @Sendable (_ value: T) -> Void
    var receiver: Receiver? = nil

    nonisolated
    let taskQueue: SerialTaskQueue

    var valuesBacklog: [T] = []

    public init(
        cancelOnDeinit: Bool = true,
        receiver: Receiver? = nil
    ) {
        self.receiver = receiver
        taskQueue = SerialTaskQueue(cancelOnDeinit: cancelOnDeinit)
    }

    deinit {
        receiver = nil
    }
}

// MARK: - Public

extension Collector {
    /// Publish a value to the receiver.
    ///
    /// If the receiver is not assigned, the value will be retained and then released
    /// once a receiver is assigned.
    nonisolated
    public func publish(_ value: sending T) {
        taskQueue.async { [self] in
            await self._send(value)
        }
    }

    /// Set the receiver handler that values will be published to.
    nonisolated
    public func setReceiver(_ receiver: Receiver?) {
        taskQueue.async { [self] in
            await _setReceiver(receiver)

            guard let receiver else { return }
            await _pushBacklog(to: receiver)
        }
    }

    /// Returns `true` if the receiver handler has been set.
    public var isReceiverSet: Bool {
        receiver != nil
    }
}

// MARK: - Internal

extension Collector {
    func _setReceiver(_ receiver: Receiver?) {
        self.receiver = receiver
    }

    func _send(_ value: sending T) {
        guard let receiver else {
            _addToBacklog(value: value)
            return
        }

        _pushBacklog(to: receiver)
        _push(value: value, to: receiver)
    }

    func _addToBacklog(value: sending T) {
        valuesBacklog.append(value)
    }

    func _push(value: sending T, to receiver: Receiver) {
        receiver(value)
    }

    func _pushBacklog(to receiver: Receiver) {
        let values = valuesBacklog
        valuesBacklog.removeAll()
        for value in values {
            _push(value: value, to: receiver)
        }
    }
}
