// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

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
