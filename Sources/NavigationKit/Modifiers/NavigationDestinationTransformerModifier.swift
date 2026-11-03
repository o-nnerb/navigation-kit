// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

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
                    let transformer = NavigationDestinationTransformer(.removeUntil)
                    closure(transformer, item)
                    return perform(AnyHashable.self, with: transformer).map {
                        .removeUntil($0)
                    }

                case .removeIncluding(let item):
                    let transformer = NavigationDestinationTransformer(.removeIncluding)
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

    /// Replaces the items of one type with the items of another type before they reach the stack.
    ///
    /// Use it when a destination is registered for a model, say `UserModel`, with
    /// ``SwiftUICore/View/nkNavigationDestination(for:destination:)``, but the code that navigates only
    /// knows a wider type, such as `enum UserScene { case model(UserModel) }`. Every
    /// ``NavigationAction`` below this view that receives a `UserScene` calls the closure, and the item
    /// given to the transformer is what ends up in the stack.
    ///
    /// ```swift
    /// .navigationDestinationTransformer(for: UserScene.self) { transformer, scene in
    ///     switch scene {
    ///     case .model(let userModel):
    ///         transformer(userModel)
    ///     }
    /// }
    /// ```
    ///
    /// The transformer is applied to `append(_:)`, `setItems(_:)`, `remove(_:)`, `removeIncluding(_:)`,
    /// `removeUntil(_:)` and `contains(_:)`. When the closure does not call the transformer for an
    /// item, that item is used as it came, so it needs a destination of its own.
    ///
    /// - Parameters:
    ///    - itemType: The type of item associated with the transformer.
    ///    - closure: The closure that accepts a NavigationDestinationTransformer instance
    /// and an item of the specified type. You can use the provided transformer to customize the
    /// destination view associated with the item.
    ///
    /// - Returns: A modified view with a navigation destination transformer configured for the
    /// specified item type.
    public func navigationDestinationTransformer<Item: Hashable & Sendable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationDestinationTransformer, Item) -> Void
    ) -> some View {
        modifier(NavigationDestinationTransformerModifier(closure: closure))
    }
}
