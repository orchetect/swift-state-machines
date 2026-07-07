//
//  StateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineProtocol<StateID>: ~Copyable {
    associatedtype StateID: Hashable, Sendable
    var stateWithResources: StateMachineStateWithResources<StateID> { get }

    init(stateWithResources: consuming StateMachineStateWithResources<StateID>)

    func update(stateWithResources: consuming StateMachineStateWithResources<StateID>)
}

// MARK: - Inits

extension StateMachineProtocol where Self: ~Copyable {
    public init<S: StateMachineState<StateID>>(initialState: consuming S, resources: consuming S.StateResources) {
        self.init(stateWithResources: StateMachineStateWithResources(state: initialState, resources: resources))
    }

    public init<S: StateMachineState<StateID>>(initialState: consuming S) where S.StateResources == Never {
        self.init(stateWithResources: StateMachineStateWithResources(state: initialState))
    }

    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID, resources: consuming S.StateResources) where S == StateID {
        self.init(stateWithResources: StateMachineStateWithResources(state: initialState, resources: resources))
    }

    @_disfavoredOverload
    public init<S: StateMachineState<StateID>>(initialState: consuming StateID) where S == StateID, S.StateResources == Never {
        self.init(stateWithResources: StateMachineStateWithResources(state: initialState))
    }
}

// MARK: - Transition

extension StateMachineProtocol where Self: ~Copyable {
    @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: S, resources: () -> S.StateResources) -> Bool {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: resources()))
        return true
    }

    @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: S) -> Bool where S.StateResources == Never {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState))
        return true
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: StateID, resources: () -> S.StateResources) -> Bool where S == StateID {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState, resources: resources()))
        return true
    }

    @_disfavoredOverload @discardableResult
    public func transition<S: StateMachineState<StateID>>(to newState: StateID) -> Bool where S == StateID, S.StateResources == Never {
        guard stateWithResources.state.canTransition(to: newState) else { return false }
        update(stateWithResources: StateMachineStateWithResources(state: newState))
        return true
    }
}

// MARK: - With Resources

extension StateMachineProtocol where Self: ~Copyable {
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        try stateWithResources.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: S,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S.StateResources == Never {
        try failureBlock()
    }

    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID {
        try stateWithResources.withResources(for: expectedState, block, wrongState: failureBlock)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always fails.")
    @_disfavoredOverload
    public func withResources<S: StateMachineState<StateID>, T, E>(
        for expectedState: StateID,
        _ block: (_ resources: inout S.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T where S == StateID, S.StateResources == Never {
        try failureBlock()
    }
}

// MARK: - Resources

extension StateMachineProtocol where Self: ~Copyable {
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? {
        stateWithResources.resources(for: expectedState)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always returns nil.")
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S.StateResources == Never {
        nil
    }

    @_disfavoredOverload
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S == StateID {
        stateWithResources.resources(for: expectedState)
    }

    @_disfavoredOverload
    @available(*, deprecated, message: "State machine state does not have resources. This always returns nil.")
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S == StateID, S.StateResources == Never {
        nil
    }
}

// MARK: - Assert

extension StateMachineProtocol where Self: ~Copyable {
    public func assertState<S: StateMachineState<StateID>>(
        is expectedState: S
    ) -> Bool {
        stateWithResources.state.stateID == expectedState.stateID
    }

    public func assertState(
        is expectedStateID: StateID
    ) -> Bool  {
        stateWithResources.state.stateID == expectedStateID
    }
}
