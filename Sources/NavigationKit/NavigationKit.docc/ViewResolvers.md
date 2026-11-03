# View Resolvers

Show the view for a model without importing the view.

## Overview

``NavigationAction`` is for screens that are pushed. A view resolver covers the rest: the root of the
app, a tab, the content of a sheet, or a screen that belongs to another module. In all of them the
code that needs the screen holds a model and asks for the view.

### Register the views

``SwiftUICore/View/viewResolver(for:_:)`` registers the view for a type. It applies to the view it is called
on and everything below it:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .viewResolver(for: LoginScene.self) { LoginCoordinator($0) }
                .viewResolver(for: HomeScene.self) { HomeCoordinator($0) }
        }
    }
}
```

The models have to be `Hashable` and `Sendable`.

### Ask for a view

A view reads ``ViewResolver`` from the environment and calls it with the model:

```swift
struct RootView: View {
    @Environment(\.viewResolver) private var viewResolver
    @State private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            viewResolver(HomeScene())
        } else {
            viewResolver(LoginScene())
        }
    }
}
```

`RootView` does not import the module that has `LoginCoordinator`, only the module that has the
`LoginScene` model. The view that comes back sees the same environment as `RootView`, including its
``NavigationAction`` and ``SceneAction``.

Reading `viewResolver` where nothing was registered above stops the program, and so does resolving a
type that was never registered. Register every model that is resolved, and do it in one place close to
the root.

### Replace a view in a preview

Because the caller only holds the model, a preview or a test can register a different view for it:

```swift
#Preview {
    RootView()
        .viewResolver(for: HomeScene.self) { _ in Text("Home") }
        .viewResolver(for: LoginScene.self) { _ in Text("Login") }
}
```

### Present a view when an action is sent

The modifiers that present a sheet, a popover or a full-screen cover build their content with the
resolver, so the `viewResolver(for:_:)` calls have to be applied after them, further out in the
hierarchy. They are described in <doc:SceneActions>.

## Topics

### Resolving

- ``ViewResolver``
- ``SwiftUICore/EnvironmentValues/viewResolver``
- ``SwiftUICore/View/viewResolver(for:_:)``
