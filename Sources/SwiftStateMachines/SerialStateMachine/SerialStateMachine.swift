//
//  SerialStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public struct SerialStateMachine<StateID: Hashable & Sendable>: SerialStateMachineProtocol {
    public typealias StateID = StateID
    public var stateWithResources: StateMachineStateWithResources<StateID>

    let lock = NSLock()

    public init(stateWithResources: StateMachineStateWithResources<StateID>) {
        self.stateWithResources = stateWithResources
    }
}

extension SerialStateMachine {
    public func _lock() -> Bool {
        lock.lock(before: .init())
    }

    public func _unlock() {
        lock.unlock()
    }
}
