# Coordinators

Keep the decision of where to go out of the view and out of the view model.

## Overview

A screen has three jobs that are easy to mix up: showing data, deciding what the data means, and
deciding which screen comes next. NavigationKit does not require an architecture, but it makes a
split natural:

- The **view** shows state and reports what the user did.
- The **view model** holds the state and decides what happened, for example that a user was
  selected. It does not know any other screen.
- The **coordinator** is a view that wraps the two and turns what happened into navigation.

The coordinator is the only one that reads ``NavigationAction`` or ``SceneAction``. Moving a screen to a
different place in the app, or navigating to it from somewhere else, changes the coordinator and
nothing else.

### Create the view model with ObjectConnection

A coordinator is a view value, and SwiftUI creates it again whenever its parent is evaluated. The
view model must not be created again with it. ``ObjectConnection`` creates the view model from the
input of the screen, keeps it while the input is equal, and creates a new one when it changes:

```swift
struct UsersScene: Hashable {
    let organization: String
}

struct UsersCoordinator: View {
    let scene: UsersScene

    var body: some View {
        ObjectConnection(scene, UsersViewModel.init) { viewModel in
            UsersView(viewModel: viewModel)
        }
    }
}
```

The scene is the input, so it must be `Hashable`, which a model that is pushed already is.

### Report where to go with SceneTransaction

The view model needs a way to say that the user chose something without holding a reference to
the coordinator. ``SceneTransaction`` is that channel. The view model declares what it can ask for and
triggers it by calling the transaction:

```swift
@MainActor
final class UsersViewModel: ObservableObject {

    enum Destination: Sendable {
        case profile(ProfileScene)
        case failure(Failure)
    }

    let transaction = SceneTransaction<Destination>()

    @Published private(set) var users: [User] = []

    init(_ scene: UsersScene) {
        // ...
    }

    func select(_ user: User) {
        transaction(.profile(ProfileScene(userID: user.id)))
    }
}
```

The coordinator iterates the transaction while its view is on screen and acts on each destination:

```swift
struct UsersCoordinator: View {
    @Environment(\.navigationAction) private var navigationAction
    @Environment(\.sceneAction) private var sceneAction

    let scene: UsersScene

    var body: some View {
        ObjectConnection(scene, UsersViewModel.init) { viewModel in
            UsersView(viewModel: viewModel)
                .task {
                    for await destination in viewModel.transaction.values {
                        switch destination {
                        case .profile(let scene):
                            navigationAction.append(scene)
                        case .failure(let failure):
                            sceneAction(failure)
                        }
                    }
                }
        }
    }
}
```

A destination triggered while nobody iterates `values` is dropped, and a new iteration does not see
past values. A transaction is meant for events that follow a user action, not for state; keep state in
the view model's properties.

`.failure` goes through ``SceneAction``, which is how a screen reports something that is not
its business to handle, such as an error shown by an alert elsewhere. See <doc:SceneActions>.

### Using Observation

The view model does not need to be an `ObservableObject`. With the Observation framework (iOS 17,
tvOS 17, macOS 14, watchOS 10, visionOS 1), mark it `@Observable`. `ObjectConnection` and
`SceneTransaction` work the same way:

```swift
@Observable
@MainActor
final class UsersViewModel {
    let transaction = SceneTransaction<Destination>()
    private(set) var users: [User] = []
    // ...
}
```

Where Observation is not available, keep `ObservableObject`. Both can coexist in the same app.

### Know when the screen is on screen

``SwiftUICore/View/viewState(_:keyPath:)`` writes `.active` to a property of the view model when the
view appears and `.inactive` when it disappears. The view model reacts in `didSet`, or by observing
the property, to load data only when the screen is shown:

```swift
@MainActor
final class UsersViewModel: ObservableObject {
    var viewState: ViewState = .inactive {
        didSet {
            if viewState == .active {
                Task { await load() }
            }
        }
    }
    // ...
}

UsersView(viewModel: viewModel)
    .viewState(viewModel, keyPath: \.viewState)
```

## Topics

### Building the screen

- ``ObjectConnection``
- ``SceneTransaction``
- ``ViewState``
