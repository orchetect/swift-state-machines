//
//  AsyncStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// Note: Using Mutex allows properties to be accessible externally without `await`.
import struct Synchronization.Mutex

/// State machine with definable conditional transition logic.
///
/// In order to implement a custom set of states, conform a type (typically an enum) to the
/// ``StateMachineState`` protocol.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public actor AsyncStateMachine<State: AsyncStateMachineState>: Sendable {
    nonisolated
    public internal(set) var state: TransitionableAsyncStateMachineState<State> {
        get { _state.withLock(\.self) }
        set { _state.withLock { $0 = newValue } }
    }

    nonisolated
    private let _state: Mutex<TransitionableAsyncStateMachineState<State>>

    nonisolated
    public internal(set) var context: State.Context {
        get { _context.withLock(\.self) }
        set { _context.withLock { $0 = newValue } }
    }

    nonisolated
    private let _context: Mutex<State.Context>

    public init(initialState: State, initialContext: State.Context? = nil) {
        _state = .init(.state(initialState))
        _context = .init(initialContext ?? State.defaultContext)
    }
}
