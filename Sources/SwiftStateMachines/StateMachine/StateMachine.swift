//
//  StateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.NSLock
import struct Synchronization.Mutex

/// State machine with definable conditional transition logic.
///
/// In order to implement a custom set of states, conform a type (typically an enum) to the
/// ``StateMachineState`` protocol.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
nonisolated
public struct StateMachine<State: StateMachineState>: Sendable, ~Copyable {
    nonisolated
    public internal(set) var state: TransitionableStateMachineState<State> {
        get { _state.withLock(\.self) }
        nonmutating set { _state.withLock { $0 = newValue } }
    }

    nonisolated
    private let _state: Mutex<TransitionableStateMachineState<State>>

    nonisolated
    public internal(set) var context: State.Context {
        get { _context.withLock(\.self) }
        nonmutating set { _context.withLock { $0 = newValue } }
    }

    nonisolated
    private let _context: Mutex<State.Context>

    nonisolated
    let lock = NSLock()

    nonisolated
    public init(initialState: consuming State, initialContext: consuming State.Context? = nil) {
        _state = .init(.state(initialState))
        _context = .init(initialContext ?? State.defaultContext)
    }
}
