//
//  StartableObjectStateMachine.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Contains an object state machine that can start and stop, as well as stop permanently.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
open class StartableObjectStateMachine<Object: StartableObject> {
    let stateMachine: StateMachine<StartableObjectStateMachineState<Object>> = .init(initialState: .stopped)

    public init() { }

    // MARK: - Lifecycle

    @discardableResult
    public final func start(configuration: Object.StartConfiguration) -> Self {
        stateMachine.withTransition(to: .started(configuration)) { oldState, context in
            // empty; `StartableObjectStateMachineState` and `StartableObject` do the work
        }
        return self
    }

    public final func stop() {
        stateMachine.withTransition(to: .stopped) { oldState, context in
            // empty; `StartableObjectStateMachineState` and `StartableObject` do the work
        }
    }

    public final func stopPermanently() {
        stateMachine.withTransition(to: .stoppedPermanently) { oldState, context in
            // empty; `StartableObjectStateMachineState` and `StartableObject` do the work
        }
    }

    // MARK: - Properties
    
    /// Returns the current object lifecycle state.
    public final var lifecycleState: StartStopStateMachineState {
        stateMachine.state.currentState.asStartableStateMachineState
    }

    /// Returns the internal object if it has been started.
    public final var startedObject: Object? {
        stateMachine.context
    }
}
