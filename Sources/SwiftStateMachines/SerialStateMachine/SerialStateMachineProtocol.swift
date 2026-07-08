//
//  SerialStateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol SerialStateMachineProtocol: StateMachineProtocol, ~Copyable {
    /// Access the state machine within a scoped exclusive lock.
    func withLock<E, T>(
        _ block: (_ stateMachine: borrowing Self) throws(E) -> T,
        lockFailure: () throws(E) -> T
    ) throws(E) -> T

    func withLock<E, T>(
        _ block: borrowing (_ stateMachine: borrowing Self) async throws(E) -> T,
        lockFailure: () async throws(E) -> T
    ) async throws(E) -> T
}

// MARK: - With Lock Variants (Non-Async)

extension SerialStateMachineProtocol where Self: ~Copyable {
    /// Access the state machine within a scoped exclusive lock, throwing the specified error if the lock cannot be acquired.
    public func withLock<E, T>(
        _ block: (_ stateMachine: borrowing Self) throws(E) -> T,
        throwing lockFailureError: E
    ) throws(E) -> T {
        try withLock { sm throws(E) in
            try block(sm)
        } lockFailure: { () throws(E) in
            throw lockFailureError
        }
    }

    /// Access the state machine within a scoped exclusive lock, failing silently if the lock cannot be acquired.
    public func withLockIfAvailable<E>(
        _ block: (_ stateMachine: borrowing Self) throws(E) -> Void
    ) throws(E) -> Void {
        try withLock { sm throws(E) in
            try block(sm)
        } lockFailure: { () throws(E) in
            // void
        }
    }
}

// MARK: - With Lock Variants (Async)

extension SerialStateMachineProtocol {
    /// Access the state machine within a scoped exclusive lock, throwing the specified error if the lock cannot be acquired.
    public func withLock<E, T>(
        _ block: sending (_ stateMachine: borrowing Self) async throws(E) -> T,
        throwing lockFailureError: E
    ) async throws(E) -> T {
        try await withLock { [block] sm async throws(E) in
            try await block(sm)
        } lockFailure: { () async throws(E) in
            throw lockFailureError
        }
    }

    /// Access the state machine within a scoped exclusive lock, failing silently if the lock cannot be acquired.
    public func withLockIfAvailable<E>(
        _ block: sending (_ stateMachine: borrowing Self) async throws(E) -> Void
    ) async throws(E) -> Void {
        try await withLock { [block] sm async throws(E) in
            try await block(sm)
        } lockFailure: { () async throws(E) in
            // void
        }
    }
}
