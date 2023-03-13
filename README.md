[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrennobemoura%2Fnavigation-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brennobemoura/navigation-kit)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrennobemoura%2Fnavigation-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brennobemoura/navigation-kit)
[![Tests](https://github.com/brennobemoura/navigation-kit/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/brennobemoura/navigation-kit/actions/workflows/tests.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/516f7228a532b73b5540/test_coverage)](https://codeclimate.com/github/brennobemoura/navigation-kit/test_coverage)

# NavigationKit

The NavigationKit is a library thats extends SwiftUI implementation for
NavigationStack (iOS 16+ only) and adds more resources to managed the
user interface.

## Installation

This repository is distributed through SPM, being possible to use it 
in two ways:

1. Xcode

In Xcode 14, go to `File > Packages > Add Package Dependency...`, then paste in 
`https://github.com/brennobemoura/navigation-kit.git`

2. Package.swift

```swift
// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/brennobemoura/navigation-kit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: ["RequestDL"]
        )
    ]
)
```

## Usage

The main features available are the ones listed down below. For each one there is
a problem solving solution that was developed thinking to solve the coupled SwiftUI's
View 

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

Using the NKNavigationStack replaces the NavigationPath with NavigationAction
that allows developers to manipulate in a better way the current stacked views.

⚠️ The downside of this implementation is the removal of Decode option that Apple
offers to us. But you can still implement your own version of NavigationStack
with NavigationPath and use the NavigationKit without the NavigationAction 
environment.

```swift
struct FirstView: View {

    @Environment(\.navigationAction) var navigationAction
    
    var body: some View {
        Button("Push") {
            // SomeModel needs to be mapped using
            // navigationDestination(for:destination:)
            // using SwiftUI's method.
            navigationAction.append(SomeModel())
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

To map the model with the corresponding view, it's available
the viewResolver(for:\_:) that needs to be specified one
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
            // the sceneActionEnabled() called in the root
            // hierarchy.
            sceneAction(SomeModel())
        }
    }
}
```

To map the action it's necessary to call the sceneAction(for:perform:) method
which will capture the action thrown in every place that it might be listened.

⚠️ SceneAction environment is only available when sceneActionEnabled() method is
called before.

```swift
struct ContentView: View {

    var body: some View {
        NKNavigationStack {
            FirstView()
        }
        .sceneAction(for: SomeModel.self) {
            print("Action received: \($0)")
        }
        // but, sceneActionEnabled is needed before 
        // somewhere in the application
        .sceneActionEnabled()
    }
}
```

Suggestion: call sceneActionEnabled in App's body property.

### ViewModelConnection

The ViewModelConnection makes possible to connect a ViewModel into a
View keeping the SwiftUI State sync and upright.

This implementation was design to be used inside Coordinator struct.

```swift
struct SecondCoordinator: View {

    let model: SomeModel
    
    var body: some View {
        ViewModelConnection(model, SecondViewModel.init) { viewModel in
            SecondView(viewModel: viewModel)
        }
    }
}
```

To managed the flow as Coordinator was meant to be, you need to specify the
destination property for the ViewModel as you can work like this:

```swift
struct SecondCoordinator: View {

    let model: SomeModel
    
    var body: some View {
        ViewModelConnection(model, SecondViewModel.init) { viewModel in
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

Inside the errorScene or thirdScene you can call the navigationAction or
sceneAction to perform something.
