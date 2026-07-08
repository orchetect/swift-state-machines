//
//  StateMachineProtocol+Assert.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

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
