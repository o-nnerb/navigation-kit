/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

struct NavigationDestinationTransformerModifier<Item: Hashable & Sendable>: ViewModifier {

    @Environment(\.navigationAction) var navigationAction

    let closure: (NavigationDestinationTransformer, Item) -> Void

    func body(content: Content) -> some View {
        content
            .environment(\._navigationAction, makeEngine().build())
    }
}

extension NavigationDestinationTransformerModifier {

    @MainActor
    struct Engine {

        let navigationAction: NavigationAction
        let closure: (NavigationDestinationTransformer, Item) -> Void

        private func perform<Destination>(
            _ type: Destination.Type,
            with transformer: NavigationDestinationTransformer
        ) -> Destination? {
            transformer.perform(navigationAction) as? Destination
        }

        func build() -> NavigationAction {
            navigationAction.resolver(for: Item.self) {
                switch $0 {
                case .append(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .append($0)
                    }

                case .setItems(let items):
                    let transformer = NavigationDestinationTransformer(.setItems)
                    for item in items {
                        closure(transformer, item)
                    }
                    return perform([AnyHashable].self, with: transformer).map {
                        .setItems($0)
                    }

                case .removeUntil(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .removeUntil($0)
                    }

                case .removeIncluding(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .removeIncluding($0)
                    }

                case .remove(let item):
                    let transformer = NavigationDestinationTransformer(.remove)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .remove($0)
                    }

                case .contains(let item):
                    let transformer = NavigationDestinationTransformer(.contains)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .contains($0)
                    }
                }
            }
        }
    }

    func makeEngine() -> Engine {
        Engine(
            navigationAction: navigationAction,
            closure: closure
        )
    }
}

extension View {

    /**
     A modifier that configures a navigation destination transformer for a specific type of `Item`.

     This modifier can be used when you have a `UserView` that is associated with a `UserModel`
     using `navigationDestination(for:destination:)`, but the type specified in the
     `NavigationAction` is an `enum UserState` that contains a `case model(UserModel)`.

     Using the `navigationDestinationTransformer(for:closure:)` method, you can transform
     the `UserState` into a `UserModel`. This method allows you to provide a closure that takes a
     `NavigationDestinationTransformer` and an `Item` (in this case, a `UserState`),
     and returns `Void`.

     Within this closure, you can extract the `UserModel` from the `UserState` and pass it to the
     `NavigationDestinationTransformer`, which will then perform the action with the `UserModel`
     which will call the `UserView` defined at `navigationDestination(for:destination:)`.

     Example usage:

     ```swift
     navigationDestinationTransformer(for: UserState.self) { transformer, scene in
         switch scene {
         case .model(let userModel):
             transformer(userModel)
         default:
             // The NavigationAction will be ignored and the
             // current app navigation state unchanged
             break
         }
     }
     ```

     - Parameters:
        - itemType: The type of item associated with the transformer.
        - closure: The closure that accepts a NavigationDestinationTransformer instance
     and an item of the specified type. You can use the provided transformer to customize the
     destination view associated with the item.

     - Returns: A modified view with a navigation destination transformer configured for the
     specified item type.
     */
    public func navigationDestinationTransformer<Item: Hashable & Sendable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationDestinationTransformer, Item) -> Void
    ) -> some View {
        modifier(NavigationDestinationTransformerModifier(closure: closure))
    }
}
