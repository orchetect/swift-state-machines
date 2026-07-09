//
//  StateMachineStateStorage.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock

public final class StateMachineStateStorage<StateID: Hashable & Sendable>: StateMachineStateStorageProtocol {
    public var state: any StateMachineState<StateID>
    public var resources: Any

    public init<State: StateMachineState<StateID>>(state: consuming State, resources: consuming State.StateResources) {
        self.state = state
        self.resources = resources
    }

    public init<State: StateMachineState<StateID>>(state: consuming State) where State.StateResources == Never {
        self.state = state
        self.resources = ()
    }
}
