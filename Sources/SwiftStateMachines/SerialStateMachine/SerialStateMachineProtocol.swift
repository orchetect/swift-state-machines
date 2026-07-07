//
//  SerialStateMachineProtocol.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol SerialStateMachineProtocol: StateMachineProtocol {
    /// Access the state machine within a scoped exclusive lock.
    mutating func withLock<E, T>(
        _ block: (_ stateMachine: inout Self) throws(E) -> T,
        lockFailure: () throws(E) -> T
    ) throws(E) -> T
}

extension SerialStateMachineProtocol {
    /// Access the state machine within a scoped exclusive lock, throwing the specified error if the lock cannot be acquired.
    public mutating func withLock<E, T>(
        _ block: (_ stateMachine: inout Self) throws(E) -> T,
        throwing lockFailureError: E
    ) throws(E) -> T {
        try withLock { sm throws(E) in
            try block(&sm)
        } lockFailure: { () throws(E) in
            throw lockFailureError
        }
    }

    /// Access the state machine within a scoped exclusive lock, failing silently if the lock cannot be acquired.
    public mutating func withLockIfAvailable<E>(
        _ block: (_ stateMachine: inout Self) throws(E) -> Void
    ) throws(E) -> Void {
        try withLock { sm throws(E) in
            try block(&sm)
        } lockFailure: { () throws(E) in
            // void
        }
    }
}
