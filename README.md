# Swift State Machines

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Forchetect%2Fswift-state-machines%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/orchetect/swift-state-machines) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Forchetect%2Fswift-state-machines%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/orchetect/swift-state-machines) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/swift-state-machines/blob/main/LICENSE)

General-purpose state machine types for Swift.

This package aims to offer flexible, modern, thread-safe abstractions.

## Getting Started

This package provides building blocks to define your own set of states, conditional transition logic, and abstractions to serialize transition changes so that a overlapping calls to the same transition are not repeated.

One of the high-level abstractions avilable combines all of these building blocks into a general-purpose, ready-to-use object lifecycle manager called `StartStopStateMachine`.

In its most basic form, it acts as a start/stop state machine:

```swift
public class MyService {
    private let lifecycle = StartStopStateMachine()

    public func start() {
        lifecycle.start {
            // perform synchronized work to start the service
        }
    }

    public func stop() {
        lifecycle.stop {
            // perform synchronized work to teardown the service
        }
    }
}
```

## Managed Resources

The `StartStopStateMachine` type may be specialized to contain resources that are created and prepared during the transition to the **started** state, and torn down during the transition to the **stopped** state.

The lifecycle of the inner resources is managed by the state machine, and concurrent state transitions are serialized to retain the integrity of the state machine and its held resources.

```swift
public class MyService {
    private let lifecycle = StartStopStateMachine<Model>()

    public func start() {
        lifecycle.start {
            let model = Model()
            model.setup()
            return model
        }
    }

    public func stop() {
        lifecycle.stop { model in
            model.teardown()
        }
    }
}

extension MyService {
    private struct Model: Sendable {
        var value: Int = 0
        init() { }

        func setup() { }
        func teardown() { }
        mutating func increment() { value += 1 }
    }
}
```

There are various ways to check the current state and interact with managed resources. These are a few basic examples:

```swift
extension MyService {
    public func doSomethingWithoutCore() throws {
        guard lifecycle.assertState(is: .started) else { throw SomeError() }
        // asserts state is started, but we don't need access to the model instance
    }

    public func readModel() throws {
        guard let model = lifecycle.startedResources else { throw SomeError() }
        // the started resources are returned as an immutable copy
        print(model.value)
    }

    public func mutateModel() throws {
        try lifecycle.withStartedResources { model in
            // the started resources are available as mutable `inout` within scope
            model.increment()
        } wrongState: { throw SomeError() }
    }
}
```

The library includes many more methods and types to provide maximum flexibility to fit your implementation requirements.

## Installation: Swift Package Manager (SPM)

### Swift Package Manager (SPM)

To add this package to an Xcode app project, use:

 `https://github.com/orchetect/swift-state-machines` as the URL.

To add this package to a Swift package, add the dependency to your package and target in Package.swift:

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-state-machines", from: "0.1.0")
    ],
    targets: [
        .target(
            dependencies: [
                .product(name: "SwiftStateMachines", package: "swift-state-machines")
            ]
        )
    ]
)
```

## Documentation

Formal documentation is currently a WIP. Complete docs coverage and additional example code is planned for a future releasee.

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](https://github.com/orchetect/swift-state-machines/blob/master/LICENSE) for details.

## Community & Support

Please do not email maintainers for technical support. Several options are available for issues and questions:

- Questions and feature ideas can be posted to [Discussions](https://github.com/orchetect/swift-state-machines/discussions).
- If an issue is a verifiable bug with reproducible steps it may be posted in [Issues](https://github.com/orchetect/swift-state-machines/issues).

## Contributions

Contributions are welcome. Posting in [Discussions](https://github.com/orchetect/swift-state-machines/discussions) first prior to new submitting PRs for features or modifications is encouraged.

## Code Quality & AI Contribution Policy

In an effort to maintain a consistent level of code quality and safety, this repository was built by hand and is maintained without the use of AI code generation.

AI-assisted contributions are welcome, but must remain modest in scope, maintain the same degree of quality and care, and be thoroughly vetted before acceptance.
