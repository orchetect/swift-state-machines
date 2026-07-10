//
//  AppleScript TransitionAutonomously Tests.swift
//  Dipper © 2023-2026 Existential Audio
//

#if os(macOS)

import Foundation
import SwiftStateMachines
import Testing

@Suite struct AppleScript_TransitionAutonomously_Tests {
    @Test
    func checkAppleScript() async throws {
        let script = AppleScript(source: #"tell application "Finder" to get version"#)
        let descriptor = try await script.run()
        #expect(descriptor.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
    }
}

fileprivate final class AppleScript {
    let lifecycle: SendableStateMachine<ScriptStateID>

    fileprivate init(source: String) {
        lifecycle = .init(initialState: .new, resources: source)
    }

    // NSAppleScript is supposed to be created and interacted with on the main thread
    @MainActor
    @discardableResult
    fileprivate func run() throws(AppleScriptError) -> sending NSAppleEventDescriptor {
        var status: StateMachineTransitionResult = .completed
        while status != .failed {
            switch lifecycle.stateStorage.state.stateID {
            case .new:
                status = try lifecycle.transition(to: .syntaxChecked).genericResult
            case .syntaxChecked:
                status = try lifecycle.transition(to: .compiled).genericResult
            case .compiled:
                status = try lifecycle.transition(to: .executed).genericResult
            case .executed:
                guard let descriptor = lifecycle.resources(for: .executed)?.descriptor.wrapped else {
                    status = .failed
                    continue
                }

                return descriptor
            }
        }

        throw .internalInconsistency
    }

    static func compile(script: NSAppleScript) throws(AppleScriptError) {
        var errorDict: NSDictionary?
        guard script.compileAndReturnError(&errorDict) else {
            let dict = (errorDict ?? NSDictionary())
            throw .compilationError(info: dict)
        }
    }

    static func execute(script: NSAppleScript) throws(AppleScriptError) -> NSAppleEventDescriptor {
        var errorDict: NSDictionary?
        let descriptor = script.executeAndReturnError(&errorDict)
        if let errorDict {
            throw .executionError(info: errorDict)
        }
        return descriptor
    }
}

extension AppleScript: Sendable { }

// MARK: - State ID

extension AppleScript {
    enum ScriptStateID: String, Sendable {
        case new
        case syntaxChecked
        case compiled
        case executed
    }
}

extension AppleScript {
    struct NewState: StateMachineState {
        fileprivate typealias StateResources = String
        fileprivate let stateID: AppleScript.ScriptStateID = .new

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: true
            case .compiled: false
            case .executed: false
            }
        }
    }
}

extension AppleScript {
    struct SyntaxCheckedState: StateMachineState {
        fileprivate typealias StateResources = LockBox<NSAppleScript>
        fileprivate let stateID: AppleScript.ScriptStateID = .syntaxChecked

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compiled: true
            case .executed: false
            }
        }
    }
}

extension AppleScript.SyntaxCheckedState: AutonomousStateMachineState {
    fileprivate typealias TransitionFailure = AppleScriptError

    fileprivate func transition<StateMachine: StateMachineProtocol<StateID> & ~Copyable>(
        in stateMachine: borrowing StateMachine
    ) throws(TransitionFailure) -> StateMachineTransitionCompletion<Self> {
        guard let source = stateMachine.resources(for: .new) else { return .failed }
        guard let script = NSAppleScript(source: source) else { throw .invalidSource }
        return .completed(with: LockBox(wrapped: script))
    }
}

extension AppleScript {
    struct CompiledState: StateMachineState {
        fileprivate typealias StateResources = LockBox<NSAppleScript>
        fileprivate let stateID: AppleScript.ScriptStateID = .compiled

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compiled: false
            case .executed: true
            }
        }
    }
}

extension AppleScript.CompiledState: AutonomousStateMachineState {
    fileprivate typealias TransitionFailure = AppleScriptError

    fileprivate func transition<StateMachine: StateMachineProtocol<StateID> & ~Copyable>(
        in stateMachine: borrowing StateMachine
    ) throws(TransitionFailure) -> StateMachineTransitionCompletion<Self> {
        guard var lockbox = stateMachine.resources(for: .syntaxChecked) else { return .failed }
        try lockbox.withObject { nsAppleScript throws(AppleScriptError) in
            try AppleScript.compile(script: nsAppleScript)
        }
        return .completed(with: lockbox)
    }
}

extension AppleScript {
    struct ExecutedState: StateMachineState {
        fileprivate typealias StateResources = (script: LockBox<NSAppleScript>, descriptor: LockBox<NSAppleEventDescriptor>)
        fileprivate let stateID: AppleScript.ScriptStateID = .executed

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compiled: false
            case .executed: true
            }
        }
    }
}

extension AppleScript.ExecutedState: AutonomousStateMachineState {
    fileprivate typealias TransitionFailure = AppleScriptError

    fileprivate func transition<StateMachine: StateMachineProtocol<StateID> & ~Copyable>(
        in stateMachine: borrowing StateMachine
    ) throws(TransitionFailure) -> StateMachineTransitionCompletion<Self> {
        guard var lockbox = stateMachine.resources(for: .compiled) else { return .failed }

        let result = try lockbox.withObject { nsAppleScript throws(AppleScriptError) in
            try AppleScript.execute(script: nsAppleScript)
        }
        return .completed(with: (script: lockbox, descriptor: LockBox(wrapped: result)))
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == AppleScript.NewState {
    static var new: Self { Self() }
}

extension StateMachineState where Self == AppleScript.SyntaxCheckedState {
    static var syntaxChecked: Self { .init() }
}

extension StateMachineState where Self == AppleScript.CompiledState {
    static var compiled: Self { .init() }
}

extension StateMachineState where Self == AppleScript.ExecutedState {
    static var executed: Self { .init() }
}

// MARK: - Error

fileprivate enum AppleScriptError: Error, @unchecked Sendable {
    case invalidSource
    case internalInconsistency
    case compilationError(info: NSDictionary)
    case executionError(info: NSDictionary)
}

// MARK: - Utilities

/// Wrapper to make an a non-Sendable type Sendable.
fileprivate struct LockBox<T>: Sendable {
    nonisolated(unsafe) var wrapped: T
    let lock = NSLock()

    fileprivate init(wrapped: T) {
        self.wrapped = wrapped
    }

    @discardableResult
    fileprivate mutating func withObject<R, E>(_ block: (_ wrapped: inout T) throws(E) -> R) throws(E) -> R {
        let result: Result<R, E> = lock.withLock {
            do throws(E) {
                return .success(try block(&wrapped))
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }
}

#endif
