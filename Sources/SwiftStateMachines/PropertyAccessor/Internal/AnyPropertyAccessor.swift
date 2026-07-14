//
//  AnyPropertyAccessor.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

enum AnyPropertyAccessor<Object: Sendable> {
    case property(any PropertyAccessor<Object>)
    case asyncProperty(any AsyncPropertyAccessor<Object>)
}
