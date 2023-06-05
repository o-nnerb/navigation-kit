/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct NavigationDestinationModifier<Item: Hashable, Destination: View>: ViewModifier {

    @Environment(\.navigationAction) var navigationAction
    @Environment(\.sceneAction) var sceneAction
    @Environment(\._viewResolver) var viewResolver

    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Item.self) {
                destination($0)
                    .environment(\._navigationAction, navigationAction)
                    .environment(\.sceneAction, sceneAction)
                    .environment(\._viewResolver, viewResolver)
            }
    }
}

extension View {

    public func nkNavigationDestination<Item: Hashable, Destination: View>(
        for item: Item.Type,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        modifier(NavigationDestinationModifier(destination: destination))
    }
}
