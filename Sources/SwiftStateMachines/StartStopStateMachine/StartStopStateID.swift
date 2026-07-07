//
//  StartStopStateID.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

public enum StartStopStateID<StartedResources>: String {
    case started
    case stopped
    case stoppedPermanently
}

extension StartStopStateID: Sendable { }
