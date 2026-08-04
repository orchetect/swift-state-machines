//
//  TestActor.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Dedicated actor for concurrency-related unit tests.
@globalActor
actor TestActor {
    static let shared = TestActor()
}
