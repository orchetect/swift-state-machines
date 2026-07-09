//
//  StateMachineProtocol+Init.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID, resources: consuming sending S.StateResources) where S == StateID {
        self.init(initialState: initialState, resources: resources)
    }

    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID) where S == StateID, S.StateResources == Never {
        self.init(initialState: initialState)
    }
}
