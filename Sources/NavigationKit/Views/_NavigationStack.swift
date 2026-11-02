// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// The navigation stack of the system, used where `NavigationStack` is available.
@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
struct _NavigationStack<Content: View>: View {

    @ObservedObject var navigationState: NavigationState
    private let pendingItems: PendingNavigationItems?
    private let content: Content

    init(
        navigationState: NavigationState,
        pendingItems: PendingNavigationItems?,
        content: Content
    ) {
        self.navigationState = navigationState
        self.pendingItems = pendingItems
        self.content = content
    }

    var body: some View {
        NavigationStack(path: $navigationState[pendingItems]) {
            content
        }
    }
}

/// The navigation stack of NavigationKit: the system one where it is available and the fallback
/// everywhere else.
///
/// - `isEmbedded` is `true` when the stack is the detail of a split view, which already provides the
///   container the fallback needs.
struct _NavigationStackHost<Content: View>: View {

    let storage: NavigationStateStorage
    let pendingItems: PendingNavigationItems?
    let isEmbedded: Bool
    let content: Content

    var body: some View {
        #if os(iOS) || os(tvOS) || os(macOS)
        if let fallback = storage.fallback {
            _FallbackNavigationStack(
                state: fallback,
                pendingItems: pendingItems,
                isEmbedded: isEmbedded,
                content: content
            )
        } else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            systemStack
        }
        #else
        systemStack
        #endif
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    private var systemStack: some View {
        _NavigationStack(
            navigationState: storage.systemState,
            pendingItems: pendingItems,
            content: content
        )
    }
}
