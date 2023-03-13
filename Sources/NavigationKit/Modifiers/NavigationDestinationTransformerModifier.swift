/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct NavigationDestinationTransformerModifier<Item: Hashable>: ViewModifier {

    @Environment(\.navigationAction) var navigationAction

    let closure: (NavigationDestinationTransformer, Item) -> Void

    func body(content: Content) -> some View {
        content
            .environment(\._navigationAction,  navigationAction.resolver(for: Item.self) {
                switch $0 {
                case .append(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    transformer.perform(navigationAction)

                case .setItems(let items):
                    let transformer = NavigationDestinationTransformer(.setItems)
                    for item in items {
                        closure(transformer, item)
                    }
                    transformer.perform(navigationAction)

                case .removeUntil(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    transformer.perform(navigationAction)

                case .removeIncluding(let item):
                    let transformer = NavigationDestinationTransformer(.append)
                    closure(transformer, item)
                    transformer.perform(navigationAction)
                }
            })
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
    public func navigationDestinationTransformer<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationDestinationTransformer, Item) -> Void
    ) -> some View {
        modifier(NavigationDestinationTransformerModifier(closure: closure))
    }
}
