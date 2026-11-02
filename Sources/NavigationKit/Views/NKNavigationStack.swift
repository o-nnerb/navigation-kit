// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// A navigation stack that manages a navigation state object and provides a way to push new views
/// onto the stack.
///
/// This view uses the `NavigationStack` implementation to actually manage the state and
/// perform the navigation where it is available (iOS 16, tvOS 16, macOS 13) and an equivalent
/// implementation on the earlier OS versions NavigationKit supports. It also sets the
/// `navigationAction` environment value to a `NavigationAction` object that provides a way for
/// child views to push new views onto the stack.
///
/// Map the items to their views with ``SwiftUI/View/nkNavigationDestination(for:destination:)``,
/// which works on every supported OS version.
public struct NKNavigationStack<Content: View>: View {

    @StateObject var storage = NavigationStateStorage()
    private let pendingItems: PendingNavigationItems?
    private let content: Content

    /// Initializes a new instance of the navigation stack with the provided content.
    ///
    /// - Parameters:
    ///   - content: The content view.
    public init(@ViewBuilder content: () -> Content) {
        self.pendingItems = nil
        self.content = content()
    }

    /// Initializes a new instance of the navigation stack with the provided sequence
    /// of items and content.
    ///
    /// - Parameters:
    ///    - sequence: The sequence of items to add to the stack.
    ///    - content: The content view.
    public init<S: Sequence>(
        _ sequence: S,
        @ViewBuilder content: () -> Content
    ) where S.Element: Hashable {
        self.pendingItems = .init(sequence)
        self.content = content()
    }

    /// Initializes a new instance of the navigation stack with the provided stack
    /// representation and content.
    ///
    /// - Parameters:
    ///    - representation: The stack codable representation.
    ///    - content: The content view.
    public init(
        _ representation: NavigationAction.CodableRepresentation?,
        @ViewBuilder content: () -> Content
    ) {
        self.pendingItems = representation.map { .init($0) }
        self.content = content()
    }

    public var body: some View {
        _NavigationStackHost(
            storage: storage,
            pendingItems: pendingItems,
            isEmbedded: false,
            content: content
        )
        .environment(\._navigationAction, NavigationAction(storage.state))
    }
}
