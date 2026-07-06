//
//  EmptyStateMachineStateContext.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public struct EmptyStateMachineStateContext: StateMachineStateContext {
    static public var defaultContext: Self { .init() }

    init() { }
}
