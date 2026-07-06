//
//  StartableObjectStateMachine Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing
import struct Synchronization.Mutex

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
fileprivate class Foo: StartableObjectStateMachine<FooGuts> { }

fileprivate class FooGuts: StartableObject {
    typealias StartConfiguration = Bool

    required init() { }

    func start(configuration: Bool) -> Bool {
        configuration
    }

    func stop() {

    }
}

@Suite
struct StartableObjectStateMachine_Tests {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func startStop() {
        let foo = Foo()

        foo.start(configuration: false)
        #expect(foo.lifecycleState == .stopped)

        foo.start(configuration: true)
        #expect(foo.lifecycleState == .started)

        foo.stop()
        #expect(foo.lifecycleState == .stopped)

        foo.start(configuration: true)
        #expect(foo.lifecycleState == .started)

        foo.stopPermanently()
        #expect(foo.lifecycleState == .stoppedPermanently)

        foo.start(configuration: true)
        #expect(foo.lifecycleState == .stoppedPermanently)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func gutsAccess() {
        let foo = Foo()

        #expect(foo.startedObject == nil)

        foo.start(configuration: true)
        #expect(foo.startedObject != nil)

        foo.stop()
        #expect(foo.startedObject != nil)

        foo.stopPermanently()
        #expect(foo.startedObject == nil)

        foo.start(configuration: true)
        #expect(foo.startedObject == nil)
    }
}
