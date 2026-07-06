//
//  AsyncStateMachine+Transition.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - State Transition

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension AsyncStateMachine {
    /// Submits a request to transition to a new state and execute the given block
    /// if the transition is successful.
    @_disfavoredOverload
    public func withTransition<E>(
        to newState: State,
        _ block: sending @escaping @isolated(any) (_ oldState: State, _ context: State.Context) async throws(E) -> Void
    ) async throws(E) {
        let oldState: State = switch state {
        case let .state(currentState):
            currentState
        case let .transitioning(fromState: _, toState: toState):
            toState
        }

        // ensure the transition is allowed
        guard await oldState.canTransition(to: newState, context: &context) else { return }

        // mutate context in anticipation and ensure the transition prep succeeded
        guard await oldState.willTransition(to: newState, context: &context) else { return }

        // perform the block in order to transition
        state = .transitioning(fromState: oldState, toState: newState)
        do throws(E) {
            try await block(oldState, context)
        } catch {
            state = .state(oldState)
            throw error
        }
        state = .state(newState)

        // mutate context after transition
        await oldState.didTransition(to: newState, context: &context)
    }

    /// Submits a request to transition to a new state and execute the given block
    /// if the transition is successful.
    public func withTransition<E>(
        to newState: State,
        _ block: sending @escaping @isolated(any) () async throws(E) -> Void
    ) async throws(E) {
        try await withTransition(to: newState, { _, _ throws(E) in try await block() })
    }
}
