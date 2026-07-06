//
//  StartableActorStateMachineState.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// States for an actor state machine that can start and stop, as well as stop permanently.
public enum StartableActorStateMachineState<Object: StartableActor> {
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

extension StartableActorStateMachineState: Equatable where Object.StartConfiguration: Equatable { }

extension StartableActorStateMachineState: Hashable where Object.StartConfiguration: Hashable { }

extension StartableActorStateMachineState: Sendable { }

extension StartableActorStateMachineState: CustomStringConvertible {
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

extension StartableActorStateMachineState: AsyncStateMachineState {
    public typealias Context = Object?

    public static var defaultContext: Context { nil }

    public func canTransition(to newState: Self, context: inout Context) async -> Bool {
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

    public func willTransition(to newState: Self, context: inout Context) async -> Bool {
        switch newState {
        case let .started(startConfiguration):
            if context == nil {
                context = .init()
            }
            guard let context else { return false }
            let isSuccess = await context.start(configuration: startConfiguration)
            return isSuccess
            
        case .stopped:
            await context?.stop()
            return true

        case .stoppedPermanently:
            await context?.stop()
            context = nil
            return true
        }
    }

    public func didTransition(to newState: Self, context: inout Context) async {
        // empty
    }
}

// MARK: - Properties

extension StartableActorStateMachineState {
    public var asStartableStateMachineState: StartStopStateMachineState {
        switch self {
        case .started(_): .started
        case .stopped: .stopped
        case .stoppedPermanently: .stoppedPermanently
        }
    }
}
