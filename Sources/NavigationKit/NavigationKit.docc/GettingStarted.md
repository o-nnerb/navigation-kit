# Getting Started

Add the package, create a stack and push a screen.

## Overview

This walks through the smallest useful setup: a stack with a home screen that opens a profile. The
other articles build on it.

### Add the package

In Xcode, choose **File > Add Package Dependencies...** and enter
`https://github.com/o-nnerb/navigation-kit.git`. In a `Package.swift`, add it as a dependency and to
the target:

```swift
dependencies: [
    .package(url: "https://github.com/o-nnerb/navigation-kit.git", from: "2.0.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "NavigationKit", package: "navigation-kit")
        ]
    )
]
```

The package needs Swift 6.4 or later.

### Describe the destination

A destination is any `Hashable` value. Instead of a view, the code that navigates creates this
value, and a separate declaration says which view it opens:

```swift
struct ProfileScene: Hashable {
    let userID: Int
}
```

### Create the stack

Wrap the root view in ``NKNavigationStack`` and register the view of each destination with
``SwiftUICore/View/nkNavigationDestination(for:destination:)``. It takes the place of SwiftUI's
`navigationDestination(for:destination:)` and also works before iOS 16, tvOS 16 and macOS 13:

```swift
struct ContentView: View {
    var body: some View {
        NKNavigationStack {
            HomeView()
                .nkNavigationDestination(for: ProfileScene.self) {
                    ProfileView(scene: $0)
                }
        }
    }
}
```

### Push and pop

Every view inside the stack reads ``NavigationAction`` from the environment:

```swift
struct HomeView: View {
    @Environment(\.navigationAction) private var navigationAction

    var body: some View {
        Button("Open profile") {
            navigationAction.append(ProfileScene(userID: 1))
        }
    }
}

struct ProfileView: View {
    @Environment(\.navigationAction) private var navigationAction

    let scene: ProfileScene

    var body: some View {
        VStack {
            Text("User \(scene.userID)")
            Button("Back to the start") {
                navigationAction.removeAll()
            }
        }
    }
}
```

`HomeView` only knows `ProfileScene`. Which view is shown for it is decided where the stack is
created, so it can change, or be replaced in a preview, without touching `HomeView`.

### Where to go next

- <doc:NavigationStacks> covers the operations on the stack, split views and saving the stack.
- <doc:ViewResolvers> and <doc:SceneActions> cover showing screens that are not pushed, and
  communicating with parts of the app that the view does not know.
- <doc:ModularApps> shows how the pieces fit in an app divided in modules.
