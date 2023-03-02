//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

extension View {

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
