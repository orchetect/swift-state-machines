//
//  AnyStateMachineStateStorage.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Internal type used to move state resource storage around without worrying about
/// its implementation details.
struct AnyStateMachineStateStorage<StateID: Hashable & Sendable>: @unchecked Sendable {
    let state: any StateMachineState<StateID>
    let resourcesClosure: () -> Any

    init<S: StateMachineState<StateID>>(state: S, resources: S.StateResources) {
        self.state = state
        self.resourcesClosure = { resources }
    }

    init<S: StateMachineState<StateID>>(state: S) where S.StateResources == Never {
        self.state = state
        self.resourcesClosure = { }
    }
}
