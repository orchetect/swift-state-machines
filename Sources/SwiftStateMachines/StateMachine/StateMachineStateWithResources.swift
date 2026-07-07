//
//  StateMachineStateWithResources.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public class StateMachineStateWithResources<StateID: Hashable & Sendable> {
    var state: any StateMachineState<StateID>
    var resources: Any

    init<State: StateMachineState<StateID>>(state: State, resources: State.StateResources) {
        self.state = state
        self.resources = resources
    }

    init<State: StateMachineState<StateID>>(state: State) where State.StateResources == Never {
        self.state = state
        self.resources = ()
    }
}

extension StateMachineStateWithResources {
    func withResources<State: StateMachineState<StateID>, T, E>(
        for expectedState: State,
        _ block: (_ resources: inout State.StateResources) throws(E) -> T,
        wrongState failureBlock: () throws(E) -> T
    ) throws(E) -> T {
        guard state is State else { return try failureBlock() }
        return try withUnsafeMutablePointer(to: &resources) { ptr throws(E) in
            try ptr.withMemoryRebound(to: State.StateResources.self, capacity: 1) { pointer throws(E) in
                try block(&pointer.pointee)
            }
        }
    }

    func resources<State: StateMachineState<StateID>>(for expectedState: State) -> State.StateResources? {
        guard state is State else { return nil }
        return (resources as! State.StateResources)
    }
}
