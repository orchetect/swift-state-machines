//
//  StateMachine+Transition.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock
import struct Synchronization.Mutex

// MARK: - State Transition (Non-Async)

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension StateMachine {
    /// Submits a request to transition to a new state and execute the given block
    /// if the transition is successful.
    nonisolated
    public func withTransition<E>(
        to newState: State,
        _ block: (_ oldState: State, _ context: State.Context) throws(E) -> Void
    ) throws(E) {
        guard lock.lock(before: .now) else { return }
        defer { lock.unlock() }

        let oldState: State = switch state {
        case let .state(currentState):
            currentState
        case let .transitioning(fromState: _, toState: toState):
            toState
        }

        // ensure the transition is allowed
        guard oldState.canTransition(to: newState, context: &context) else { return }

        // mutate context in anticipation and ensure the transition prep succeeded
        guard oldState.willTransition(to: newState, context: &context) else { return }

        // perform the block in order to transition
        state = .transitioning(fromState: oldState, toState: newState)
        do throws(E) {
            try block(oldState, context)
        } catch {
            state = .state(oldState)
            throw error
        }
        state = .state(newState)

        // mutate context after transition
        oldState.didTransition(to: newState, context: &context)
    }

    /// Submits a request to transition to a new state and execute the given block
    /// if the transition is successful.
    nonisolated
    public func withTransition<E>(
        to newState: State,
        _ block: () throws(E) -> Void
    ) throws(E) {
        try withTransition(to: newState, { _, _ throws(E) in try block() })
    }
}

// MARK: - State Transition (Async)

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension StateMachine {
    /// Submits a request to transition to a new state and execute the given block
    /// if the transition is successful.
    nonisolated
    public func withTransition<E>(
        to newState: State,
        _ block: (_ oldState: State, _ context: State.Context) async throws(E) -> Void
    ) async throws(E) {
        let acquireLock = { [lock] in lock.lock(before: .now) }
        guard acquireLock() else { return }
        defer { { lock.unlock() }() }

        let oldState: State = switch state {
        case let .state(currentState):
            currentState
        case let .transitioning(fromState: _, toState: toState):
            toState
        }

        // ensure the transition is allowed
        guard oldState.canTransition(to: newState, context: &context) else { return }

        // mutate context in anticipation and ensure the transition prep succeeded
        guard oldState.willTransition(to: newState, context: &context) else { return }

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
        oldState.didTransition(to: newState, context: &context)
    }
}
