//
//  AppleScript TransitionFromTo Tests.swift
//  Dipper © 2023-2026 Existential Audio
//

#if os(macOS)

import Foundation
import SwiftStateMachines
import Testing

@Suite struct AppleScript_TransitionFromTo_Tests {
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
        // check syntax
        try lifecycle.transition(from: .new, to: .syntaxChecked) { source throws(AppleScriptError) in
            guard let script = NSAppleScript(source: source) else { throw .invalidSource }
            return .completed(with: LockBox(wrapped: script))
        }

        // compile
        lifecycle.transition(from: .syntaxChecked, to: .compilationSuccess) { lockbox in
            do throws(AppleScriptError) {
                try lockbox.withObject { nsAppleScript throws(AppleScriptError) in
                    try Self.compile(script: nsAppleScript)
                }
                return .completed(with: lockbox)
            } catch {
                return .failed(withNewState: .compilationFailure, resources: error)
            }
        }

        // check for compilation error
        if let error = lifecycle.resources(for: .compilationFailure) {
            throw error
        }

        // execute
        lifecycle.transition(from: .compilationSuccess, to: .executionSuccess) { lockbox in
            do throws(AppleScriptError) {
                let result = try lockbox.withObject { nsAppleScript throws(AppleScriptError) in
                    try Self.execute(script: nsAppleScript)
                }
                return .completed(with: (script: lockbox, descriptor: LockBox(wrapped: result)))
            } catch {
                return .failed(withNewState: .executionFailure, resources: (script: lockbox, error: error))
            }
        }

        // check for execution error
        if let error = lifecycle.resources(for: .executionFailure)?.error {
            throw error
        }

        // check for execution result
        guard let result = lifecycle.resources(for: .executionSuccess) else {
            throw .internalInconsistency
        }

        return result.descriptor.wrapped
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
        case compilationSuccess
        case compilationFailure
        case executionSuccess
        case executionFailure
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
            case .compilationSuccess, .compilationFailure: false
            case .executionSuccess, .executionFailure: false
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
            case .compilationSuccess, .compilationFailure: true
            case .executionSuccess, .executionFailure: false
            }
        }
    }
}

extension AppleScript {
    struct CompilationSuccessState: StateMachineState {
        fileprivate typealias StateResources = LockBox<NSAppleScript>
        fileprivate let stateID: AppleScript.ScriptStateID = .compilationSuccess

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compilationSuccess: false
            case .compilationFailure: false
            case .executionSuccess, .executionFailure: true
            }
        }
    }
}

extension AppleScript {
    struct CompilationFailureState: StateMachineState {
        fileprivate typealias StateResources = AppleScriptError
        fileprivate let stateID: AppleScript.ScriptStateID = .compilationFailure

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compilationSuccess: false
            case .compilationFailure: false
            case .executionSuccess, .executionFailure: true
            }
        }
    }
}

extension AppleScript {
    struct ExecutionSuccessState: StateMachineState {
        fileprivate typealias StateResources = (script: LockBox<NSAppleScript>, descriptor: LockBox<NSAppleEventDescriptor>)
        fileprivate let stateID: AppleScript.ScriptStateID = .executionSuccess

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compilationSuccess: false
            case .compilationFailure: false
            case .executionSuccess, .executionFailure: true
            }
        }
    }
}

extension AppleScript {
    struct ExecutionFailureState: StateMachineState {
        fileprivate typealias StateResources = (script: LockBox<NSAppleScript>, error: AppleScriptError)
        fileprivate let stateID: AppleScript.ScriptStateID = .executionFailure

        fileprivate func canTransition(to newState: some StateMachineState<StateID>) -> Bool {
            switch newState.stateID {
            case .new: false
            case .syntaxChecked: false
            case .compilationSuccess: false
            case .compilationFailure: false
            case .executionSuccess, .executionFailure: true
            }
        }
    }
}

// MARK: - Static Constructors

extension StateMachineState where Self == AppleScript.NewState {
    static var new: Self { Self() }
}

extension StateMachineState where Self == AppleScript.SyntaxCheckedState {
    static var syntaxChecked: Self { .init() }
}

extension StateMachineState where Self == AppleScript.CompilationSuccessState {
    static var compilationSuccess: Self { .init() }
}

extension StateMachineState where Self == AppleScript.CompilationFailureState {
    static var compilationFailure: Self { .init() }
}

extension StateMachineState where Self == AppleScript.ExecutionSuccessState {
    static var executionSuccess: Self { .init() }
}

extension StateMachineState where Self == AppleScript.ExecutionFailureState {
    static var executionFailure: Self { .init() }
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
