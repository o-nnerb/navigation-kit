/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct DynamicModifierViewModifier<Key>: ViewModifier {

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

    @available(macOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(iOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(tvOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(watchOS, deprecated, introduced: 9999, message: "This method needs a review")
    public func modifier<Item>(for type: Item.Type) -> some View {
        modifier(DynamicModifierViewModifier<Item>())
    }

    @available(macOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(iOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(tvOS, deprecated, introduced: 9999, message: "This method needs a review")
    @available(watchOS, deprecated, introduced: 9999, message: "This method needs a review")
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
