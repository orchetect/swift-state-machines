//
//  StateMachineProtocol+Init.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - Non-Async

extension StateMachineProtocol where Self: ~Copyable {
    public init<S: StateMachineState<StateID>>(initialState: consuming sending S, resources: consuming S.StateResources) {
        self.init(stateWithResources: StateMachineStateStorage(state: initialState, resources: resources))
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming sending S) where S.StateResources == Never {
        self.init(stateWithResources: StateMachineStateStorage(state: initialState))
    }

    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID, resources: consuming S.StateResources) where S == StateID {
        self.init(stateWithResources: StateMachineStateStorage(state: initialState, resources: resources))
    }

    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID) where S == StateID, S.StateResources == Never {
        self.init(stateWithResources: StateMachineStateStorage(state: initialState))
    }
}
