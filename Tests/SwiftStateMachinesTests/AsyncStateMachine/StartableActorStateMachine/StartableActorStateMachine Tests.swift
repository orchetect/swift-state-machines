//
//  StartableActorStateMachine Tests.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftStateMachines
import Testing
import struct Synchronization.Mutex

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
fileprivate class Foo: StartableActorStateMachine<FooGuts> { }

fileprivate actor FooGuts: StartableActor {
    typealias StartConfiguration = Bool

    init() { }

    func start(configuration: Bool) -> Bool {
        configuration
    }

    func stop() {

    }
}

@Suite
struct StartableActorStateMachine_Tests {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func startStop() async {
        let foo = Foo()

        await foo.start(configuration: false)
        #expect(foo.lifecycleState == .stopped)

        await foo.start(configuration: true)
        #expect(foo.lifecycleState == .started)

        await foo.stop()
        #expect(foo.lifecycleState == .stopped)

        await foo.start(configuration: true)
        #expect(foo.lifecycleState == .started)

        await foo.stopPermanently()
        #expect(foo.lifecycleState == .stoppedPermanently)

        await foo.start(configuration: true)
        #expect(foo.lifecycleState == .stoppedPermanently)
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test
    func gutsAccess() async {
        let foo = Foo()

        #expect(foo.startedObject == nil)

        await foo.start(configuration: true)
        #expect(foo.startedObject != nil)

        await foo.stop()
        #expect(foo.startedObject != nil)

        await foo.stopPermanently()
        #expect(foo.startedObject == nil)

        await foo.start(configuration: true)
        #expect(foo.startedObject == nil)
    }
}
