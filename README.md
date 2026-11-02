[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fo-nnerb%2Fnavigation-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/o-nnerb/navigation-kit)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fo-nnerb%2Fnavigation-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/o-nnerb/navigation-kit)
[![codecov](https://codecov.io/gh/o-nnerb/navigation-kit/branch/main/graph/badge.svg?token=C1KZ4624FC)](https://codecov.io/gh/o-nnerb/navigation-kit)

# NavigationKit

NavigationKit is a library that extends SwiftUI's `NavigationStack` and
`NavigationSplitView` and adds more resources to manage the user interface
and decouple views from the navigation flow.

## Requirements

- Swift 6.3 or later
- iOS 16+, tvOS 16+, macOS 13+, watchOS 9+

## Installation

This repository is distributed through the Swift Package Manager, and it can
be added in two ways:

1. Xcode

In Xcode, go to `File > Add Package Dependencies...`, then paste in
`https://github.com/o-nnerb/navigation-kit.git`

2. Package.swift

```swift
// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v13), .watchOS(.v9)],
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/o-nnerb/navigation-kit.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: [
                .product(name: "NavigationKit", package: "navigation-kit")
            ]
        )
    ]
)
```

## Usage

The main features available are the ones listed below. Each one solves a
problem caused by SwiftUI views being coupled to the navigation flow.

### NKNavigationStack

```swift
struct ContentView: View {

    var body: some View {
        NKNavigationStack {
            FirstView()
        }
    }
}
```

`NKNavigationStack` replaces the `NavigationPath` with a `NavigationAction`
that allows developers to better manipulate the currently stacked views.

⚠️ The downside of this implementation is the removal of the decode option that
Apple offers. You can still implement your own version of `NavigationStack`
with `NavigationPath` and use NavigationKit without the `NavigationAction`
environment.

```swift
struct FirstView: View {

    @Environment(\.navigationAction) var navigationAction

    var body: some View {
        Button("Push") {
            // SomeModel needs to be mapped using
            // navigationDestination(for:destination:)
            // from SwiftUI.
            navigationAction.append(SomeModel())
        }
    }
}
```

Besides `append(_:)`, the `NavigationAction` offers `setItems(_:)`, `remove(_:)`,
`removeIncluding(_:)`, `removeUntil(_:)`, `removeLast()`, `removeLast(_:)` and
`removeAll()`. Its `count` and `contains(_:)` describe the current stack, and
`codable` exposes a serializable representation that can be passed back to
the `NKNavigationStack(_:content:)` initializer to restore the stack.

### NKNavigationSplitView

`NKNavigationSplitView` is the `NavigationSplitView` counterpart: the detail
column is managed by a navigation stack, so `navigationAction` is also
available to the views inside it.

```swift
struct ContentView: View {

    var body: some View {
        NKNavigationSplitView {
            SidebarView()
        } detail: {
            DetailView()
        }
    }
}
```

### ViewResolver

```swift
struct FirstView: View {

    @Environment(\.viewResolver) var viewResolver

    var body: some View {
        // SomeModel needs to be mapped using
        // viewResolver(for:_:) {}.
        viewResolver(SomeModel())
    }
}
```

To map a model to its corresponding view, use `viewResolver(for:_:)` one
view before the usage.

```swift
struct ContentView: View {

    var body: some View {
        NKNavigationStack {
            FirstView()
                .viewResolver(for: SomeModel.self) {
                    SecondView($0)
                }
        }
    }
}
```

### SceneAction

```swift
struct FirstView: View {

    @Environment(\.sceneAction) var sceneAction

    var body: some View {
        Button("Push") {
            // SomeModel needs to be mapped using
            // sceneAction(for:perform:) and
            // sceneActionEnabled() needs to be called in the
            // root hierarchy.
            sceneAction(SomeModel())
        }
    }
}
```

To handle an action, call `sceneAction(for:perform:)`, which captures the action
sent from any view below it.

⚠️ The `sceneAction` environment is only available when `sceneActionEnabled()`
is called before.

```swift
struct ContentView: View {

    var body: some View {
        NKNavigationStack {
            FirstView()
        }
        .sceneAction(for: SomeModel.self) {
            print("Action received: \($0)")
        }
        // sceneActionEnabled() is needed somewhere
        // above in the application
        .sceneActionEnabled()
    }
}
```

Suggestion: call `sceneActionEnabled()` in the App's body property.

Scene actions can also present views directly, using the `ViewResolver` to
build the content:

```swift
ContentView()
    .sceneActionSheet(for: SomeModel.self)
    .sceneActionPopover(for: OtherModel.self)
    .sceneActionFullScreenCover(for: ThirdModel.self)
```

Use `sceneActionTransformer(for:closure:)` to map one action type into another
and `navigationDestinationTransformer(for:closure:)` to map an item type into a
destination registered with `navigationDestination(for:destination:)`.

### ObjectConnection

`ObjectConnection` connects a ViewModel to a View, keeping SwiftUI's state in
sync: the object is created, updated and disposed according to the changes of
the input value.

This implementation was designed to be used inside a Coordinator struct.

```swift
struct SecondCoordinator: View {

    // The input needs to be Hashable
    let model: SomeModel

    var body: some View {
        ObjectConnection(model, SecondViewModel.init) { viewModel in
            SecondView(viewModel: viewModel)
        }
    }
}
```

To manage the flow the way a Coordinator is meant to, expose a `destination`
property in the ViewModel and react to it:

```swift
struct SecondCoordinator: View {

    let model: SomeModel

    var body: some View {
        ObjectConnection(model, SecondViewModel.init) { viewModel in
            SecondView(viewModel: viewModel)
                .onReceive(viewModel.$destination) { destination in
                    switch destination {
                    case .error(let error):
                        errorScene(error)
                    case .third(let third):
                        thirdScene(third)
                    case .none:
                        break
                    }
                }
        }
    }
}
```

Inside `errorScene` or `thirdScene` you can call `navigationAction` or
`sceneAction` to perform something.

### ViewState

The `viewState(_:)` modifier sets a `ViewState` to `active` when the view appears
and to `inactive` when it disappears, either through a `Binding<ViewState>` or
through a key path of an object.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.
Every Swift file must start with the license header and the code must pass
`swift format lint --strict` using the repository's `.swift-format`.

## License

NavigationKit is released under the MIT license. See [LICENSE](LICENSE) for details.
