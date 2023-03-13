/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

/**
 A view that displays a split view with a sidebar, content, and detail view.

 This view uses the `NavigationSplitView` implementation to actually display the split view. It provides multiple convenience initializers for creating different types of split views with varying configurations of sidebar, content, and detail views.

 This view uses the `NavigationStack` implementation for detail to actually manage the
 state and perform the navigation. It also sets the `navigationAction` environment value
 to a `NavigationAction` object that provides a way for child views to push new views onto
 the stack.
 */
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

    /**
     Initializes a new instance of the split view with a sidebar, content, and detail view.

     - Parameters:
        - columnVisibility: A binding that controls the visibility of the sidebar column.
        - sidebar: A closure that returns the sidebar view.
        - content: A closure that returns the content view.
        - detail: A closure that returns the detail view.
     */
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

    /**
     Initializes a new instance of the split view with a sidebar and detail view.

     - Parameters:
        - columnVisibility: A binding that controls the visibility of the sidebar column.
        - sidebar: A closure that returns the sidebar view.
        - detail: A closure that returns the detail view.
     */
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

    /**
     Initializes a new instance of the split view with a sidebar, content, and detail view.

     This initializer does not include a binding to control the visibility of the sidebar column.

     - Parameters:
        - sidebar: A closure that returns the sidebar view.
        - content: A closure that returns the content view.
        - detail: A closure that returns the detail view.
     */
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

    /**
     Initializes a new instance of the split view with a sidebar and detail view.

     This initializer does not include a binding to control the visibility of the sidebar column.

     - Parameters:
        - sidebar: A closure that returns the sidebar view.
        - detail: A closure that returns the detail view.
     */
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
