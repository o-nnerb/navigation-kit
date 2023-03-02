//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

struct ModifierAttachedViewModifier<Key>: ViewModifier {

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

    public func attachModifier<Item>(for type: Item.Type) -> some View {
        modifier(ModifierAttachedViewModifier<Item>())
    }
}
