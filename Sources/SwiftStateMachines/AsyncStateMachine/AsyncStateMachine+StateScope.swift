//
//  AsyncStateMachine+StateScope.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - State Scope

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension AsyncStateMachine {
    // MARK: State Predicate

    /// Executes the given block if the current state satisfies the given predicate.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    @_disfavoredOverload
    public func withState<T: Sendable, E>(
        expecting isStateExpected: (_ state: State) -> Bool,
        _ block: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T
    ) async throws(E) -> T {
        let oldState: State = switch state {
        case let .state(currentState):
            currentState
        case let .transitioning(fromState: _, toState: toState):
            toState
        }

        guard isStateExpected(oldState) else {
            return try await failureBlock(context)
        }

        return try await block(context)
    }

    /// Executes the given block if the current state satisfies the given predicate.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    public func withState<T: Sendable, E>(
        expecting isStateExpected: (_ state: State) -> Bool,
        _ block: sending @escaping @isolated(any) () async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) () async throws(E) -> T
    ) async throws(E) -> T {
        try await withState(
            expecting: isStateExpected,
            { _ throws(E) in try await block() },
            wrongState: { _ throws(E) in try await failureBlock() }
        )
    }

    // MARK: Specific State

    /// Executes the given block if the current state is equal to the expected state.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    @_disfavoredOverload
    public func withState<T: Sendable, E>(
        expecting expectedState: State,
        _ block: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T
    ) async throws(E) -> T where State: Equatable {
        try await withState(
            expecting: { $0 == expectedState },
            block,
            wrongState: failureBlock
        )
    }

    /// Executes the given block if the current state is equal to the expected state.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    public func withState<T: Sendable, E>(
        expecting expectedState: State,
        _ block: sending @escaping @isolated(any) () async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) () async throws(E) -> T
    ) async throws(E) -> T where State: Equatable {
        try await withState(
            expecting: expectedState,
            { _ throws(E) in try await block() },
            wrongState: { _ throws(E) in try await failureBlock() }
        )
    }

    // MARK: Set of States

    /// Executes the given block if the current state is equal to one of the expected states.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    @_disfavoredOverload
    public func withState<T: Sendable, E>(
        expecting expectedStates: Set<State>,
        _ block: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) (_ context: State.Context) async throws(E) -> T
    ) async throws(E) -> T where State: Hashable {
        try await withState(
            expecting: { expectedStates.contains($0) },
            block,
            wrongState: failureBlock
        )
    }

    /// Executes the given block if the current state is equal to one of the expected states.
    ///
    /// If the state machine is currently transitioning to the expected state, this method waits for the the
    /// transition to complete and then executes the given block.
    ///
    /// If the state machine is not currently in the expected state or transitioning to the expected state,
    /// the failure block is executed instead of the main block.
    public func withState<T: Sendable, E>(
        expecting expectedStates: Set<State>,
        _ block: sending @escaping @isolated(any) () async throws(E) -> T,
        wrongState failureBlock: sending @escaping @isolated(any) () async throws(E) -> T
    ) async throws(E) -> T where State: Hashable {
        try await withState(
            expecting: expectedStates,
            { _ throws(E) in try await block() },
            wrongState: { _ throws(E) in try await failureBlock() }
        )
    }
}
