//
//  File.swift
//  
//
//  Created by Brenno on 12/03/23.
//

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

    public func navigationDestinationTransformer<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationDestinationTransformer, Item) -> Void
    ) -> some View {
        modifier(NavigationDestinationTransformerModifier(closure: closure))
    }
}
