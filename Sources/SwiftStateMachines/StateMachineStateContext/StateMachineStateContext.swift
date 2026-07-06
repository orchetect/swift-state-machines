//
//  StateMachineStateContext.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public protocol StateMachineStateContext: Sendable {
    static var defaultContext: Self { get }
}
