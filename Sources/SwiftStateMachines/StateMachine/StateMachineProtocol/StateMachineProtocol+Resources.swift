//
//  StateMachineProtocol+Resources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension StateMachineProtocol where Self: ~Copyable {
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? {
        stateStorage.resources(for: expectedState)
    }

    @available(*, deprecated, message: "State machine state does not have resources. This always returns nil.")
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S.StateResources == Never {
        nil
    }

    @_disfavoredOverload
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S == StateID {
        stateStorage.resources(for: expectedState)
    }

    @_disfavoredOverload
    @available(*, deprecated, message: "State machine state does not have resources. This always returns nil.")
    public func resources<S: StateMachineState<StateID>>(for expectedState: S) -> S.StateResources? where S == StateID, S.StateResources == Never {
        nil
    }
}
