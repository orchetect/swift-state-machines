//
//  Receiver.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines

final class Receiver<T>: Sendable {
    nonisolated
    var items: [T] {
        get {
            lock.withLock { _items }
        }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_items
        }
        set {
            lock.withLock { _items = newValue }
        }
    }

    nonisolated(unsafe)
    private var _items: [T] = []

    private let lock = NSLock()

    init() { }
}

extension Receiver {
    nonisolated
    func add(_ element: T) {
        items.append(element)
    }

    nonisolated
    func reset() {
        items.removeAll()
    }
}
