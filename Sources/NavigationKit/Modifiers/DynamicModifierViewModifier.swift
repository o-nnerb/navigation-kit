//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

struct DynamicModifierViewModifier<Key>: ViewModifier {

    @Environment(\.modifierResolver) var modifierResolver

    @ViewBuilder
    func body(content: Content) -> some View {
        if let modifierResolver {
            modifierResolver(ObjectIdentifier(Key.self))(AnyView(content))
        } else {
            content
        }
    }
}

extension View {

    public func modifier<Item>(for type: Item.Type) -> some View {
        modifier(DynamicModifierViewModifier<Item>())
    }

    public func modifierResolver<Key, Modifier: ViewModifier>(
        for type: Key.Type,
        _ modifier: @escaping () -> Modifier
    ) -> some View {
        resolver(
            keyPath: \.modifierResolver,
            init: { .init() },
            key: ObjectIdentifier(type),
            value: {
                AnyView($0.modifier(modifier()))
            }
        )
    }
}
