//
//  StateMachineTransitionCompletion.swift
//  AppleScript.swift
//  Dipper © 2023-2026 Existential Audio
//

public struct StateMachineTransitionCompletion<
    State: StateMachineState,
    StateStorage: StateMachineStateStorageProtocol
>: ~Copyable where StateStorage.StateID == State.StateID {
    let wrapped: Wrapped

    init(wrapped: Wrapped) {
        self.wrapped = wrapped
    }
}

extension StateMachineTransitionCompletion: Sendable where Wrapped: Sendable { }

// MARK: - Static Constructors

extension StateMachineTransitionCompletion {
    public static func completed(with resources: State.StateResources) -> Self {
        Self(wrapped: .completed(resources: resources))
    }

    public static func failed() -> Self {
        Self(wrapped: .failed)
    }

    public static func failed<S: StateMachineState<State.StateID>>(withNewState state: S, resources: S.StateResources) -> Self {
        Self(wrapped: .failureState(stateStorage: StateStorage(state: state, resources: resources)))
    }

    public static func failed<S: StateMachineState<State.StateID>>(withNewState state: S) -> Self where S.StateResources == Never {
        Self(wrapped: .failureState(stateStorage: StateStorage(state: state)))
    }
}

// MARK: - Wrapped

extension StateMachineTransitionCompletion {
    enum Wrapped {
        case completed(resources: State.StateResources)
        case failed
        case failureState(stateStorage: StateStorage)
    }
}

extension StateMachineTransitionCompletion.Wrapped: Sendable where State.StateResources: Sendable, StateStorage: Sendable { }
