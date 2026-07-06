# Swift State Machines

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Forchetect%2Fswift-state-machines%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/orchetect/swift-state-machines) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Forchetect%2Fswift-state-machines%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/orchetect/swift-state-machines) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/swift-state-machines/blob/main/LICENSE)

General-purpose state machine types for Swift.

This package aims to offer flexible, modern, thread-safe abstractions.

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

Most methods are implemented as category methods so they are generally discoverable.

All methods are documented with inline help explaining their purpose and basic usage examples.

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