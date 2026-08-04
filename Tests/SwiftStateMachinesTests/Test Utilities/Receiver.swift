//
//  Receiver.swift
//  SwiftStateMachines • https://github.com/orchetect/swift-state-machines
//  © 2026 Steffan Andrews • Licensed under MIT License
//

actor Receiver<T> {
    var items: [T] = []

    init() { }

    func add(_ element: T) {
        print(element)
        items.append(element)
    }

    func reset() {
        items.removeAll()
    }
}
