//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

public struct NKNavigationStack<Content: View>: View {

    @StateObject var navigationState = NavigationState()
    private let pendingItems: PendingNavigationItems?
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.pendingItems = nil
        self.content = content()
    }

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

    public var body: some View {
        _NavigationStack(
            navigationState: navigationState,
            pendingItems: pendingItems,
            content: content
        )
        .environment(\._navigationAction, NavigationAction(navigationState))
    }
}
