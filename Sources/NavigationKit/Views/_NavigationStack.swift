//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

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
