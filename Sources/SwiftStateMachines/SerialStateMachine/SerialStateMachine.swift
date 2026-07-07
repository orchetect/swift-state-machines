//
//  SerialStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public struct SerialStateMachine<StateID: Hashable & Sendable>: StateMachineProtocol {
    public typealias StateID = StateID
    public var stateWithResources: StateMachineStateWithResources<StateID>

    let lock = NSLock()

    public init(stateWithResources: StateMachineStateWithResources<StateID>) {
        self.stateWithResources = stateWithResources
    }
}

extension SerialStateMachine {
    func _lock() -> Bool {
        lock.lock(before: .init())
    }

    func _unlock() {
        lock.unlock()
    }
}

extension SerialStateMachine: SerialStateMachineProtocol {
    public mutating func withLock<E, T>(
        _ block: (_ stateMachine: inout Self) throws(E) -> T,
        lockFailure: () throws(E) -> T
    ) throws(E) -> T {
        guard _lock() else { return try lockFailure() }
        defer { _unlock() }

        return try block(&self)
    }
}
