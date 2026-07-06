//
//  StartStopStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// States for a state machine that can start and stop, as well as stop permanently.
public enum StartStopStateMachineState {
    /// Started and ready.
    /// (May be stopped.)
    case started

    /// Stopped.
    /// (May be started.)
    case stopped

    /// Stopped permanently (terminated).
    /// (May not be started again.)
    case stoppedPermanently
}

extension StartStopStateMachineState: CaseIterable { }

extension StartStopStateMachineState: Equatable { }

extension StartStopStateMachineState: Hashable { }

extension StartStopStateMachineState: Sendable { }

extension StartStopStateMachineState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .started:
            "Started"
        case .stopped:
            "Stopped"
        case .stoppedPermanently:
            "Stopped Permanently"
        }
    }
}

// By implementing the non-async `StateMachineState` methods, it can also satisfy
// the `AsyncStateMachineState` protocol's async overloads of each method.
extension StartStopStateMachineState: StateMachineState, AsyncStateMachineState {
    public struct Context: Equatable, Hashable, Sendable {
        /// If `true`, the state machine has not yet been started ever.
        /// If `false`, the state machine has been started at least once already.
        public internal(set) var isInitial: Bool = true

        init() { }
    }

    public static var defaultContext: Context { .init() }

    public func canTransition(to newState: Self, context: inout Context) -> Bool {
        switch self {
        case .started:
            switch newState {
            case .started: false
            case .stopped: true
            case .stoppedPermanently: true
            }
        case .stopped:
            switch newState {
            case .started: true
            case .stopped: false
            case .stoppedPermanently: true
            }
        case .stoppedPermanently:
            false
        }
    }

    public func willTransition(to newState: Self, context: inout Context) -> Bool {
        true
    }

    public func didTransition(to newState: Self, context: inout Context) {
        switch newState {
        case .started:
            if context.isInitial {
                context.isInitial = false
            }
        case .stopped:
            break
        case .stoppedPermanently:
            break
        }
    }
}
