# Organizing an App in Modules

Split an app in independent modules that navigate and talk to each other without importing each other.

## Overview

The pieces in the previous articles are small on purpose. This article puts them together in the
structure they were designed for: a host app and several mini apps, each in its own package, owned
by a different team.

The example follows the Compass Github project, a sample made of one host and three packages:

- [GithubSuperApp](https://github.com/github-brenno-compass/GithubSuperApp), the host.
- [GithubKit](https://github.com/github-brenno-compass/GithubKit), the contract shared by all of them.
- [AuthenticationApp](https://github.com/github-brenno-compass/AuthenticationApp), with the login and
  the error alert.
- [HomeApp](https://github.com/github-brenno-compass/HomeApp), with the users and their repositories.

The code below is a reduced version of it. The sample was written for the 1.0 alpha of NavigationKit
and uses The Composable Architecture for its screens, so it differs in details: it observes a
`transaction.publisher` where this library now offers `transaction.values`, and it injects the
navigation builder with a dependency container. The structure is the same.

The rule that holds it together: **a module only imports the contract, never another module.**
`HomeApp` can ask for the login screen and can tell the app to log out, and it never imports
`AuthenticationApp`.

### The contract

The shared module declares, as plain `Hashable` types, what a mini app accepts and what it announces.
The scenes are the screens other modules may open. The actions are the events other modules may
send to it.

```swift
// GithubKit

public enum AuthenticationAppScene: Hashable {
    case login(Login)

    public struct Login: Hashable {
        public init() {}
    }
}

public enum AuthenticationAppAction: Hashable {
    case error(Failure)
    case authenticated
    case logout

    public struct Failure: Hashable {
        public let message: String

        public init(message: String) {
            self.message = message
        }
    }
}

public enum HomeAppScene: Hashable {
    case home(Home)

    public struct Home: Hashable {
        public init() {}
    }
}
```

Nothing here says how a screen looks or which module builds it.

### The entry point of a mini app

Each mini app turns the scenes of the contract into views. The resolver is a view that builds the
stack of the app and applies what the app needs in it:

```swift
// HomeApp

public struct HomeAppResolver: View {
    private let scene: HomeAppScene

    public init(_ scene: HomeAppScene) {
        self.scene = scene
    }

    public var body: some View {
        switch scene {
        case .home:
            NKNavigationStack {
                UsersCoordinator(UsersScene())
                    .modifier(HomeAppDescriptor())
                    .modifier(HomeAppActions())
            }
        }
    }
}
```

The sample asks the host for a `NavigationBuilder` instead of creating the stack directly, so the host
decides how the stack is made, or whether it is a stack or a split view, depending on the device.

### The descriptor: where the screens of the app are

The descriptor is a `ViewModifier` that registers every destination of the mini app. It is the only
place that lists the screens and their coordinators:

```swift
// HomeApp

struct HomeAppDescriptor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .nkNavigationDestination(for: UsersScene.self) { UsersCoordinator($0) }
            .nkNavigationDestination(for: UserScene.self) { UserCoordinator($0) }
            .nkNavigationDestination(for: RepositoriesScene.self) { RepositoriesCoordinator($0) }
            .navigationDestinationTransformer(for: HomeFeatureScene.self) { transformer, scene in
                switch scene {
                case .users(let scene):
                    transformer(scene)
                case .repositories(let scene):
                    transformer(scene)
                }
            }
    }
}
```

When a mini app is divided in features, each feature has a descriptor of its own, and the one of the
app applies them with `.modifier(UsersFeatureDescriptor())`. The transformer lets the app navigate
with a single enum, `HomeFeatureScene`, while the destinations stay registered for the models of
each screen. See <doc:NavigationStacks>.

### The actions: how the app listens

The actions modifier translates the actions of the contract into the ones the mini app uses inside:

```swift
// AuthenticationApp

struct AuthenticationAppActions: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modifier(AlertsFeatureActions())
            .sceneActionTransformer(for: AuthenticationAppAction.self) { transformer, action in
                switch action {
                case .error(let failure):
                    transformer(AlertsFeatureAction.show(failure.message))
                default:
                    break
                }
            }
    }
}
```

`AlertsFeatureAction` never leaves the module. The alert feature handles it with
`sceneAction(for:perform:)` and shows an alert, as in <doc:SceneActions>. The contract exposes what
other modules may do, `AuthenticationAppAction.error`, and the module is free to change how it does
it.

### The host

The host is the only code that knows every mini app. It registers the resolvers, enables the
scene, and decides which scene to show:

```swift
// GithubSuperApp

@main
struct SuperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .viewResolver(for: AuthenticationAppScene.self) { AuthenticationAppResolver($0) }
                .viewResolver(for: HomeAppScene.self) { HomeAppResolver($0) }
                .sceneActionEnabled()
        }
    }
}

struct ContentView: View {
    @Environment(\.viewResolver) private var viewResolver
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                viewResolver(HomeAppScene.home(.init()))
            } else {
                viewResolver(AuthenticationAppScene.login(.init()))
            }
        }
        .sceneAction(for: AuthenticationAppAction.self) { action in
            switch action {
            case .authenticated:
                isAuthenticated = true
            case .logout:
                isAuthenticated = false
            case .error:
                break
            }
        }
    }
}
```

The host listens to `AuthenticationAppAction` for the same reason `HomeApp` can send it: both depend on
the contract and on nothing else.

### Following an action through the pieces

Take a user who logs out from a list in `HomeApp`:

1. The view model of the users screen triggers `transaction(.logout)`.
2. `UsersCoordinator` receives it and calls `sceneAction(AuthenticationAppAction.logout)`:

   ```swift
   case .logout:
       sceneAction(AuthenticationAppAction.logout)
   ```

3. The scene delivers the action to every handler of its type. `ContentView` is one of them, and
   sets `isAuthenticated` to `false`.
4. `viewResolver(AuthenticationAppScene.login(...))` now builds the login screen, from a module that
   `HomeApp` never imported.

Replace the login screen, or the way the host decides who is authenticated, and `HomeApp` is not
touched. The same holds for an error: any coordinator sends
`sceneAction(AuthenticationAppAction.error(...))`, and whichever module owns the alert shows it.

### The coordinator

Each screen of a mini app is built by a coordinator like the one in <doc:Coordinators>. It is
the layer that knows the contract:

```swift
// HomeApp

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
                        case .user(let scene):
                            navigationAction.append(scene)
                        case .error(let message):
                            sceneAction(AuthenticationAppAction.error(.init(message: message)))
                        case .logout:
                            sceneAction(AuthenticationAppAction.logout)
                        }
                    }
                }
        }
    }
}
```

### Testing a mini app on its own

Because the module only needs the host for the scene and the actions, its sample app is small. The
`Sample` target of each package in the project does what the host does for one module: registers its
resolver, calls `sceneActionEnabled()` and shows its entry scene. Actions it sends that nobody
handles are dropped, so the module can run without the others.

## Topics

### Related articles

- <doc:NavigationStacks>
- <doc:ViewResolvers>
- <doc:SceneActions>
- <doc:Coordinators>
