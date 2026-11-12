[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fo-nnerb%2Fnavigation-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/o-nnerb/navigation-kit)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fo-nnerb%2Fnavigation-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/o-nnerb/navigation-kit)
[![codecov](https://codecov.io/gh/o-nnerb/navigation-kit/branch/main/graph/badge.svg?token=C1KZ4624FC)](https://codecov.io/gh/o-nnerb/navigation-kit)

# NavigationKit

NavigationKit is a library that extends SwiftUI's `NavigationStack` and
`NavigationSplitView` and adds more resources to manage the user interface
and decouple views from the navigation flow.

## Requirements

- Swift 6.4 or later
- iOS 15+, tvOS 15+, macOS 12+, watchOS 9+, visionOS 1+

## Installation

This repository is distributed through the Swift Package Manager, and it can
be added in two ways:

1. Xcode

In Xcode, go to `File > Add Package Dependencies...`, then paste in
`https://github.com/o-nnerb/navigation-kit.git`

2. Package.swift

```swift
// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v15), .tvOS(.v15), .macOS(.v12), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/o-nnerb/navigation-kit.git", from: "2.0.0")
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

The decode option that `NavigationPath` offers is kept: `navigationAction.codable`
returns a `Codable` representation of the stack that you can save and pass back to
`NKNavigationStack` to restore it (see below). It only exists while every item in the
stack is `Codable`, so use the `Codable` overloads of `append(_:)` and `setItems(_:)`
for the items that must survive a relaunch.

```swift
struct FirstView: View {

    @Environment(\.navigationAction) var navigationAction

    var body: some View {
        Button("Push") {
            // SomeModel needs to be mapped using
            // nkNavigationDestination(for:destination:).
            navigationAction.append(SomeModel())
        }
    }
}
```

Map the items to their views with `nkNavigationDestination(for:destination:)`, which
works like SwiftUI's `navigationDestination(for:destination:)` and also on the OS
versions that do not have it:

```swift
NKNavigationStack {
    FirstView()
        .nkNavigationDestination(for: SomeModel.self) {
            SecondView($0)
        }
}
```

Besides `append(_:)`, the `NavigationAction` offers `setItems(_:)`, `remove(_:)`,
`removeIncluding(_:)`, `removeUntil(_:)`, `removeLast()`, `removeLast(_:)` and
`removeAll()`. Its `count` and `contains(_:)` describe the current stack, and
`codable` exposes a serializable representation that can be passed back to
the `NKNavigationStack(_:content:)` initializer to restore the stack.

#### Before iOS 16, tvOS 16 and macOS 13

`NavigationStack` and `NavigationPath` do not exist on iOS 15, tvOS 15 and macOS 12,
so `NKNavigationStack` and `NKNavigationSplitView` use an equivalent implementation
there. Your code is the same on every OS version, and the system implementation is
still the one used where it is available. What is different on the earlier versions:

- iOS and tvOS use a `NavigationView`; the items are shown one at a time, each one
  after the previous push finishes, because the system ignores a push started while
  another one is in progress. `setItems(_:)` with several items takes that many
  transitions to show them all.
- macOS 12 has no push navigation in `NavigationView`, so the items are stacked on top
  of the content, with a back button in the toolbar.
- The SwiftUI `navigationDestination(for:destination:)` is not available, so use
  `nkNavigationDestination(for:destination:)`, which works on every version.
- The `NKNavigationSplitView` initializers with `columnVisibility` need iOS 16,
  tvOS 16 or macOS 13.
- The `codable` representation of a stack is the same on every OS version, so one
  saved on a version restores on any other.

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
destination registered with `nkNavigationDestination(for:destination:)`.

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

#### Using Observation

`ObjectConnection` does not require the ViewModel to be an `ObservableObject`, so
an `@Observable` ViewModel works the same way: it is created once, kept while the
input is the same, created again when the input changes, and the content is
rendered again when the properties it reads change.

Since an `@Observable` type has no `$destination` publisher, react to the property
with `onChange` (the `Destination` type needs to be `Equatable`):

```swift
@Observable
@MainActor
final class SecondViewModel {
    var destination: Destination?
}

struct SecondCoordinator: View {

    let model: SomeModel

    var body: some View {
        ObjectConnection(model, SecondViewModel.init) { viewModel in
            SecondView(viewModel: viewModel)
                .onChange(of: viewModel.destination) { _, destination in
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

⚠️ The Observation framework requires iOS 17, tvOS 17, macOS 14, watchOS 10 or
visionOS 1. NavigationKit itself supports iOS 15, tvOS 15, macOS 12 and
watchOS 9, where the `ObservableObject` approach above remains the way to go.
`viewState(_:keyPath:)` also accepts an `@Observable` object.

### ViewState

The `viewState(_:)` modifier sets a `ViewState` to `active` when the view appears
and to `inactive` when it disappears, either through a `Binding<ViewState>` or
through a key path of an object.

## Documentation

The API reference and the articles, including a walkthrough of an app split in modules, are
on [Swift Package Index](https://swiftpackageindex.com/o-nnerb/navigation-kit/documentation/navigationkit).
The same catalog is in `Sources/NavigationKit/NavigationKit.docc`, and Xcode builds it with
**Product > Build Documentation**.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.
Every Swift file must start with the license header and the code must pass
`swift format lint --strict` using the repository's `.swift-format`.

## License

NavigationKit is released under the MIT license. See [LICENSE](LICENSE) for details.
