# Scene Actions

Let a view ask for something without knowing which view does it.

## Overview

A login screen has to tell the app that the user signed in. A list has to report an error that some
alert, far up in the hierarchy, will show. Neither should hold a reference to the view that reacts.

A scene action is a `Hashable` value sent through the environment. Whoever sends it does not know who
handles it; whoever handles it does not know who sent it. Actions are matched by their type.

### Enable the scene

Actions travel inside a scene, created by ``SwiftUICore/View/sceneActionEnabled()``. Call it once, above
every view that sends or handles actions. The `App` is the natural place:

```swift
WindowGroup {
    RootView()
        .sceneActionEnabled()
}
```

Without it the views do not share a scene and nothing is delivered. Calling it a second time further
down starts another scene, and what is sent below it does not reach the handlers above.

### Send an action

Define the action as a type, usually an enum, and call ``SceneAction`` from the environment:

```swift
enum SessionAction: Hashable {
    case authenticated
    case logout
}

struct LoginCoordinator: View {
    @Environment(\.sceneAction) private var sceneAction

    var body: some View {
        LoginView(onSuccess: {
            sceneAction(SessionAction.authenticated)
        })
    }
}
```

If no view handles the type, nothing happens.

### Handle an action

``SwiftUICore/View/sceneAction(for:perform:)`` runs a closure for each action of a type:

```swift
struct RootView: View {
    @State private var session = Session()

    var body: some View {
        content
            .sceneAction(for: SessionAction.self) { action in
                switch action {
                case .authenticated:
                    session.refresh()
                case .logout:
                    session.signOut()
                }
            }
    }
}
```

The handler keeps listening while another screen covers the view, so the root of a stack still
receives the actions sent from the screens pushed on top of it. It stops when the view leaves the
hierarchy. An action sent while no handler exists is dropped; a handler that appears afterwards does
not receive it.

Several views can handle the same type, and each one receives every action.

### Show an alert from anywhere

A modifier that owns the alert and handles the action keeps the rest of the app from knowing it exists:

```swift
struct Failure: Hashable {
    let message: String
}

struct FailureAlert: ViewModifier {
    @State private var failure: Failure?

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Failure.self) { failure = $0 }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { failure != nil },
                    set: { if !$0 { failure = nil } }
                ),
                actions: { Button("OK") {} },
                message: { Text(failure?.message ?? "") }
            )
    }
}
```

Apply it once, near the root, with `.modifier(FailureAlert())`. Any screen reports with
`sceneAction(Failure(message: "No connection"))`.

### Present a view

For actions that should show a screen, the presentation modifiers do the state handling. They
present the view that ``SwiftUICore/View/viewResolver(for:_:)`` has for the model, so the content has to be
registered. See <doc:ViewResolvers>.

```swift
RootView()
    .sceneActionSheet(for: HelpAction.self) { action in
        HelpScene(topic: action.topic)
    }
    .viewResolver(for: HelpScene.self) { HelpView($0) }
    .sceneActionEnabled()
```

The environment flows from the outside in, so the resolver and the scene have to be applied after
the presentation modifier, as above. The other way around, the modifier does not see them.

``SwiftUICore/View/sceneActionSheet(for:reducer:)``, ``SwiftUICore/View/sceneActionPopover(for:attachmentAnchor:arrowEdge:reducer:)``
and `sceneActionFullScreenCover(for:reducer:)` (not on macOS) take a closure that turns the action
into the model to present. The overloads without `reducer` present the action itself, so a view must
be registered for the action type.

### Translate an action

A module should handle its own actions, not the ones of the whole app.
``SwiftUICore/View/sceneActionTransformer(for:_:)`` receives an action of one type and sends another:

```swift
content
    .sceneActionTransformer(for: AppAction.self) { transformer, action in
        switch action {
        case .error(let failure):
            transformer(failure)
        default:
            break
        }
    }
```

Here an `AppAction.error` also reaches the handlers of `Failure`, such as the alert above. The original
action is not consumed, so its own handlers still receive it. Not calling the transformer sends
nothing. <doc:ModularApps> uses this to connect modules.

## Topics

### Sending and handling

- ``SceneAction``
- ``SwiftUICore/EnvironmentValues/sceneAction``
- ``SwiftUICore/View/sceneActionEnabled()``
- ``SwiftUICore/View/sceneAction(for:perform:)``

### Translating

- ``SceneActionTransformer``
- ``SwiftUICore/View/sceneActionTransformer(for:_:)``
