// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

private struct NavigationDestinationModifier<Item: Hashable, Destination: View>: ViewModifier {

    @Environment(\.navigationAction) var navigationAction
    @Environment(\.sceneAction) var sceneAction
    @Environment(\._viewResolver) var viewResolver

    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || os(macOS)
        if NavigationBackend.usesFallback {
            content
                .transformPreference(FallbackDestinationsKey.self) { destinations in
                    destinations = destinations.merging(
                        FallbackDestinations(Item.self) { AnyView(resolved($0)) }
                    )
                }
        } else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            content
                .navigationDestination(for: Item.self) {
                    resolved($0)
                }
        }
        #else
        content
            .navigationDestination(for: Item.self) {
                resolved($0)
            }
        #endif
    }

    private func resolved(_ item: Item) -> some View {
        destination(item)
            .environment(\._navigationAction, navigationAction)
            .environment(\.sceneAction, sceneAction)
            .environment(\._viewResolver, viewResolver)
    }
}

extension View {

    /// Associates a destination view with a presented data type for use within a navigation stack.
    ///
    /// Use it in place of SwiftUI's `navigationDestination(for:destination:)`: it works the same way
    /// and also on the OS versions that do not have it (before iOS 16, tvOS 16 and macOS 13).
    ///
    /// - Parameters:
    ///    - item: The type of data that this destination matches.
    ///    - destination: A view builder that defines a view to display when the stack's navigation
    /// state contains a value of type `item`.
    ///
    /// - Returns: A view that uses the destination when a value of the type is pushed.
    public func nkNavigationDestination<Item: Hashable, Destination: View>(
        for item: Item.Type,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        modifier(NavigationDestinationModifier(destination: destination))
    }
}
