/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

/**
 A navigation stack that manages a navigation state object and provides a way to push new views
 onto the stack.

 This view uses the `NavigationStack` implementation to actually manage the state and
 perform the navigation. It also sets the `navigationAction` environment value to a
 `NavigationAction` object that provides a way for child views to push new views onto
 the stack.
 */
public struct NKNavigationStack<Content: View>: View {

    @StateObject var navigationState = NavigationState()
    private let pendingItems: PendingNavigationItems?
    private let content: Content

    /**
     Initializes a new instance of the navigation stack with the provided content.

     - Parameters:
       - content: The content view.
     */
    public init(@ViewBuilder content: () -> Content) {
        self.pendingItems = nil
        self.content = content()
    }

    /**
     Initializes a new instance of the navigation stack with the provided sequence
     of items and content.

     - Parameters:
        - sequence: The sequence of items to add to the stack.
        - content: The content view.
     */
    public init<S: Sequence>(
        _ sequence: S,
        @ViewBuilder content: () -> Content
    ) where S.Element: Hashable {
        self.pendingItems = .init(
            path: .init(sequence),
            hashes: sequence.map(\.hashValue)
        )
        self.content = content()
    }

    /**
     Initializes a new instance of the navigation stack with the provided stack
     representation and content.

     - Parameters:
        - representation: The stack codable representation.
        - content: The content view.
     */
    public init(
        _ representation: NavigationAction.CodableRepresentation?,
        @ViewBuilder content: () -> Content
    ) {
        self.pendingItems = representation.map { .init($0) }
        self.content = content()
    }

    public var body: some View {
        _NavigationStack(
            navigationState: navigationState,
            pendingItems: pendingItems,
            content: content
        )
        .environment(\._navigationAction, NavigationAction(navigationState))
    }
}
