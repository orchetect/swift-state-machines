//
//  AnyStateMachineResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Internal type used to move state resources around without worrying about
/// its implementation details.
struct AnyStateMachineResources<State: StateMachineState>: @unchecked Sendable {
    let resourcesClosure: () -> State.StateResources

    init(resources: State.StateResources) {
        self.resourcesClosure = { resources }
    }

    init() where State.StateResources == Never {
        self.resourcesClosure = { fatalError() }
    }
}
