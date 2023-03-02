//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

public struct NKNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {

    @StateObject var navigationState = NavigationState()
    private let initialized: Initialized

    init(_ initialized: Initialized) {
        self.initialized = initialized
    }

    public var body: some View {
        Group {
            switch initialized {
            case .columnVisibilityFull(let columnVisibility, let sidebar, let content, let detail):
                NavigationSplitView(
                    columnVisibility: columnVisibility,
                    sidebar: { sidebar },
                    content: { content },
                    detail: {
                        _NavigationStack(
                            navigationState: navigationState,
                            pendingItems: nil,
                            content: detail
                        )
                    }
                )
            case .columnVisibility(let columnVisibility, let sidebar, let detail):
                NavigationSplitView(
                    columnVisibility: columnVisibility,
                    sidebar: { sidebar },
                    detail: {
                        _NavigationStack(
                            navigationState: navigationState,
                            pendingItems: nil,
                            content: detail
                        )
                    }
                )
            case .regularFull(let sidebar, let content, let detail):
                NavigationSplitView(
                    sidebar: { sidebar },
                    content: { content },
                    detail: {
                        _NavigationStack(
                            navigationState: navigationState,
                            pendingItems: nil,
                            content: detail
                        )
                    }
                )
            case .regular(let sidebar, let detail):
                NavigationSplitView(
                    sidebar: { sidebar },
                    detail: {
                        _NavigationStack(
                            navigationState: navigationState,
                            pendingItems: nil,
                            content: detail
                        )
                    }
                )
            }
        }
        .environment(\._navigationAction, NavigationAction(navigationState))
    }
}

extension NKNavigationSplitView {

    enum Initialized {
        case columnVisibilityFull(
            Binding<NavigationSplitViewVisibility>,
            Sidebar,
            Content,
            Detail
        )

        case columnVisibility(
            Binding<NavigationSplitViewVisibility>,
            Sidebar,
            Detail
        )

        case regularFull(
            Sidebar,
            Content,
            Detail
        )

        case regular(
            Sidebar,
            Detail
        )
    }
}

extension NKNavigationSplitView {

    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.init(.columnVisibilityFull(
            columnVisibility,
            sidebar(),
            content(),
            detail()
        ))
    }

    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) where Content == EmptyView {
        self.init(.columnVisibility(
            columnVisibility,
            sidebar(),
            detail()
        ))
    }

    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.init(.regularFull(
            sidebar(),
            content(),
            detail()
        ))
    }

    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) where Content == EmptyView {
        self.init(.regular(
            sidebar(),
            detail()
        ))
    }
}
