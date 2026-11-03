# Navigation Stacks

Change the stack from any view, use a split view, and save the stack to restore it later.

## Overview

``NKNavigationStack`` keeps the items of the stack and hands the views a ``NavigationAction`` to change
them. This article covers what that action can do beyond `append(_:)`. The setup is in
<doc:GettingStarted>.

Items are compared by their `Hashable` value. Two equal items are the same item for the operations
below, and the first one in the stack is the one found.

### Push and replace

`append(_:)` pushes one item. `setItems(_:)` replaces the whole stack, which is how a deep link is
opened: list the screens from the first to the last and set them at once. The last item is the one on
top.

The items of one call have to be of the same type, so a path through several screens is usually
described with an enum, registered as a destination like any other type:

```swift
enum OrdersRoute: Hashable {
    case list
    case detail(Int)
}

content
    .nkNavigationDestination(for: OrdersRoute.self) { route in
        switch route {
        case .list:
            OrdersView()
        case .detail(let id):
            OrderView(id: id)
        }
    }

func open(_ link: DeepLink) {
    switch link {
    case .order(let id):
        navigationAction.setItems([OrdersRoute.list, .detail(id)])
    }
}
```

When the screens are different types, clear the stack and push them in order instead:

```swift
navigationAction.removeAll()
navigationAction.append(OrdersScene())
navigationAction.append(OrderScene(id: id))
```

### Go back

Pick the operation by what should be left in the stack. Each line below starts from the same stack:

```swift
// Stack: Cart, Address, Payment, Receipt

navigationAction.removeLast()                 // Cart, Address, Payment
navigationAction.removeLast(2)                // Cart, Address
navigationAction.removeUntil(CartScene())     // Cart
navigationAction.removeIncluding(CartScene()) // empty
navigationAction.remove(AddressScene())       // Cart, Payment, Receipt
navigationAction.removeAll()                  // empty
```

`removeUntil(_:)` goes back to an item and keeps it. `removeIncluding(_:)` removes it too, which
is the one to use to leave a flow and return to the screen that started it. `remove(_:)` takes an item
out of the middle without touching the ones around it, for example a screen that should not be
reachable by going back. When the item is not in the stack, these three do nothing.

``NavigationAction/count`` and ``NavigationAction/contains(_:)`` tell what is in the stack, for when
the answer decides what to do:

```swift
if navigationAction.contains(LoginScene()) {
    navigationAction.removeIncluding(LoginScene())
}
```

### Navigate with a different type

Sometimes the code that navigates knows a wider type than the one a destination was registered
for. A module may expose a single enum with its screens, while the destinations are registered for
the model of each one. ``SwiftUICore/View/navigationDestinationTransformer(for:closure:)`` bridges them:

```swift
enum UsersFeatureScene: Hashable {
    case users(UsersScene)
    case user(UserScene)
}

content
    .nkNavigationDestination(for: UsersScene.self) { UsersCoordinator($0) }
    .nkNavigationDestination(for: UserScene.self) { UserCoordinator($0) }
    .navigationDestinationTransformer(for: UsersFeatureScene.self) { transformer, scene in
        switch scene {
        case .users(let scene):
            transformer(scene)
        case .user(let scene):
            transformer(scene)
        }
    }
```

A call such as `navigationAction.append(UsersFeatureScene.user(scene))` pushes `UserScene`, and
the same goes for the other operations. Apply the transformer after the destinations, as above, so
the screens they build use it too. If the closure does not call the transformer for an item, the
item is pushed as it came, so it needs a destination of its own.

### Split views

``NKNavigationSplitView`` is the counterpart of `NavigationSplitView`. The detail column is a stack,
so the views inside it read ``NavigationAction`` as usual. The sidebar and the content column are outside
of the stack and have no `navigationAction`.

A sidebar that changes what the detail shows can send a scene action, which the root of the detail
handles. See <doc:SceneActions>.

```swift
struct SidebarAction: Hashable {
    let folder: String
}

struct MailView: View {
    var body: some View {
        NKNavigationSplitView {
            SidebarView()
        } detail: {
            DetailRoot()
                .nkNavigationDestination(for: FolderScene.self) {
                    FolderView(scene: $0)
                }
        }
        .sceneActionEnabled()
    }
}

struct SidebarView: View {
    @Environment(\.sceneAction) private var sceneAction

    var body: some View {
        List(["Inbox", "Sent", "Archive"], id: \.self) { folder in
            Button(folder) {
                sceneAction(SidebarAction(folder: folder))
            }
        }
    }
}

struct DetailRoot: View {
    @Environment(\.navigationAction) private var navigationAction

    var body: some View {
        Text("Pick a folder")
            .sceneAction(for: SidebarAction.self) { action in
                navigationAction.setItems([FolderScene(name: action.folder)])
            }
    }
}
```

### Save and restore the stack

``NavigationAction/codable`` describes the stack in a form that can be encoded. It is `nil` when an
item in the stack is not `Codable`; append those with the `Codable` overloads of `append(_:)` and
`setItems(_:)`. Pass the decoded value to the initializer of ``NKNavigationStack`` to bring the stack
back:

```swift
enum StackStore {
    private static let key = "navigation.stack"

    static func save(_ representation: NavigationAction.CodableRepresentation?) {
        let data = representation.flatMap { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> NavigationAction.CodableRepresentation? {
        UserDefaults.standard.data(forKey: key).flatMap {
            try? JSONDecoder().decode(NavigationAction.CodableRepresentation.self, from: $0)
        }
    }
}

struct ContentView: View {
    @State private var saved = StackStore.load()

    var body: some View {
        NKNavigationStack(saved) {
            HomeView()
                .nkNavigationDestination(for: ProfileScene.self) { ProfileView(scene: $0) }
        }
    }
}
```

Read the stored value once, into `@State` as above. The initializer applies the representation again
whenever it receives a different one, so loading it on every update of the view would reset the stack
after each save.

The items are found again by the name of their type. A type that was renamed or moved to another
module since the stack was saved cannot be decoded.

To start from a known set of items instead, the initializer also takes a sequence of items of one
type: `NKNavigationStack([OrdersRoute.list, .detail(7)]) { ... }`.

## Topics

### Operating on the stack

- ``NavigationAction``
- ``NavigationAction/CodableRepresentation``
- ``NavigationDestinationTransformer``
