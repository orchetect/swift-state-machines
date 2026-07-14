//
//  PropertyUpdateResult.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Result returned from ``PropertyAccessor`` and ``AsyncPropertyAccessor`` `newValue` methods.
public enum PropertyUpdateResult<Value: Sendable>: Sendable {
    case unchanged
    case newValue(Value)
}

extension PropertyUpdateResult: Equatable where Value: Equatable { }

extension PropertyUpdateResult: Hashable where Value: Hashable { }
