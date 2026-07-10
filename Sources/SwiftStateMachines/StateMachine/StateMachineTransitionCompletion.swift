//
//  StateMachineTransitionCompletion.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct StateMachineTransitionCompletion<
    State: StateMachineState
>: ~Copyable {
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

    public static var failed: Self {
        Self(wrapped: .failed)
    }

    public static func failed<S: StateMachineState<State.StateID>>(withNewState state: S, resources: S.StateResources) -> Self {
        Self(wrapped: .failureState(storage: AnyStateMachineStateStorage(state: state, resources: resources)))
    }

    public static func failed<S: StateMachineState<State.StateID>>(withNewState state: S) -> Self where S.StateResources == Never {
        Self(wrapped: .failureState(storage: AnyStateMachineStateStorage(state: state)))
    }

    public static var skipped: Self {
        Self(wrapped: .skipped)
    }
}

// MARK: - Wrapped

extension StateMachineTransitionCompletion {
    enum Wrapped {
        case completed(resources: State.StateResources)
        case failed
        case failureState(storage: AnyStateMachineStateStorage<State.StateID>)
        case skipped
    }
}

extension StateMachineTransitionCompletion.Wrapped: Sendable where State.StateResources: Sendable { }
