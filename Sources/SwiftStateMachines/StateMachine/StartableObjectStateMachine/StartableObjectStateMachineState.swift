//
//  StartableObjectStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// States for an object state machine that can start and stop, as well as stop permanently.
public enum StartableObjectStateMachineState<Object: StartableObject> {
    /// Started and ready.
    /// (May be stopped.)
    case started(Object.StartConfiguration)

    /// Stopped.
    /// (May be started.)
    case stopped

    /// Stopped permanently (terminated).
    /// (May not be started again.)
    case stoppedPermanently
}

extension StartableObjectStateMachineState: Equatable where Object.StartConfiguration: Equatable { }

extension StartableObjectStateMachineState: Hashable where Object.StartConfiguration: Hashable{ }

extension StartableObjectStateMachineState: Sendable { }

extension StartableObjectStateMachineState: CustomStringConvertible {
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

extension StartableObjectStateMachineState: StateMachineState {
    public typealias Context = Object?

    public static var defaultContext: Context { nil }

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
        switch newState {
        case let .started(startConfiguration):
            if context == nil {
                context = .init()
            }
            guard context != nil else { return false }
            let isSuccess = context?.start(configuration: startConfiguration) ?? false
            return isSuccess

        case .stopped:
            context?.stop()
            return true

        case .stoppedPermanently:
            context?.stop()
            context = nil
            return true
        }
    }

    public func didTransition(to newState: Self, context: inout Context) {
        // empty
    }
}

// MARK: - Properties

extension StartableObjectStateMachineState {
    public var asStartableStateMachineState: StartStopStateMachineState {
        switch self {
        case .started(_): .started
        case .stopped: .stopped
        case .stoppedPermanently: .stoppedPermanently
        }
    }
}
