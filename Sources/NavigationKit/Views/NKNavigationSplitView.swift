// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// A view that displays a split view with a sidebar, content, and detail view.
///
/// This view uses the `NavigationSplitView` implementation to actually display the split view.
/// It provides multiple convenience initializers for creating different types of split views with varying
/// configurations of sidebar, content, and detail views.
///
/// This view uses the `NavigationStack` implementation for detail to actually manage the
/// state and perform the navigation. It also sets the `navigationAction` environment value
/// to a `NavigationAction` object that provides a way for child views to push new views onto
/// the stack.
///
/// ```swift
/// NKNavigationSplitView {
///     SidebarView()
/// } detail: {
///     DetailView()
///         .nkNavigationDestination(for: ItemScene.self) {
///             ItemView($0)
///         }
/// }
/// ```
///
/// Only the detail column has a ``SwiftUICore/EnvironmentValues/navigationAction``. The sidebar and the content
/// columns are outside of the stack, so reading it from there stops the program.
public struct NKNavigationSplitView<Sidebar: View, Content: View, Detail: View>: View {

    @StateObject var storage = NavigationStateStorage()
    private let initialized: Initialized

    init(_ initialized: Initialized) {
        self.initialized = initialized
    }

    /// The split view with its columns.
    public var body: some View {
        Group {
            switch initialized {
            case .regularFull(let sidebar, let content, let detail):
                layout(sidebar: sidebar, content: content, detail: detail)
            case .regular(let sidebar, let detail):
                layout(sidebar: sidebar, detail: detail)
            default:
                if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
                    columnVisibilityLayout
                }
            }
        }
        .environment(\._navigationAction, NavigationAction(storage.state))
    }

    private func detailStack(_ detail: Detail) -> some View {
        _NavigationStackHost(
            storage: storage,
            pendingItems: nil,
            isEmbedded: true,
            content: detail
        )
    }
}

// MARK: - Layouts

extension NKNavigationSplitView {

    @ViewBuilder
    private func layout(sidebar: Sidebar, content: Content, detail: Detail) -> some View {
        #if os(iOS) || os(tvOS) || os(macOS)
        if storage.fallback != nil {
            NavigationView {
                sidebar
                content
                detailStack(detail)
            }
        } else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            NavigationSplitView(
                sidebar: { sidebar },
                content: { content },
                detail: { detailStack(detail) }
            )
        }
        #else
        NavigationSplitView(
            sidebar: { sidebar },
            content: { content },
            detail: { detailStack(detail) }
        )
        #endif
    }

    @ViewBuilder
    private func layout(sidebar: Sidebar, detail: Detail) -> some View {
        #if os(iOS) || os(tvOS) || os(macOS)
        if storage.fallback != nil {
            NavigationView {
                sidebar
                detailStack(detail)
            }
        } else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            NavigationSplitView(
                sidebar: { sidebar },
                detail: { detailStack(detail) }
            )
        }
        #else
        NavigationSplitView(
            sidebar: { sidebar },
            detail: { detailStack(detail) }
        )
        #endif
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @ViewBuilder
    private var columnVisibilityLayout: some View {
        switch initialized {
        case .columnVisibilityFull(let columnVisibility, let sidebar, let content, let detail):
            NavigationSplitView(
                columnVisibility: columnVisibility.value,
                sidebar: { sidebar },
                content: { content },
                detail: { detailStack(detail) }
            )
        case .columnVisibility(let columnVisibility, let sidebar, let detail):
            NavigationSplitView(
                columnVisibility: columnVisibility.value,
                sidebar: { sidebar },
                detail: { detailStack(detail) }
            )
        default:
            EmptyView()
        }
    }
}

extension NKNavigationSplitView {

    /// The binding of the column visibility, type-erased because `NavigationSplitViewVisibility` is
    /// not available before iOS 16, tvOS 16 and macOS 13.
    struct ColumnVisibility {

        private let binding: Any

        @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
        init(_ binding: Binding<NavigationSplitViewVisibility>) {
            self.binding = binding
        }

        @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
        var value: Binding<NavigationSplitViewVisibility> {
            guard let binding = binding as? Binding<NavigationSplitViewVisibility> else {
                preconditionFailure("The column visibility is not a NavigationSplitViewVisibility binding")
            }

            return binding
        }
    }

    enum Initialized {
        case columnVisibilityFull(
            ColumnVisibility,
            Sidebar,
            Content,
            Detail
        )

        case columnVisibility(
            ColumnVisibility,
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

    /// Initializes a new instance of the split view with a sidebar, content, and detail view.
    ///
    /// - Parameters:
    ///    - columnVisibility: A binding that controls the visibility of the sidebar column.
    ///    - sidebar: A closure that returns the sidebar view.
    ///    - content: A closure that returns the content view.
    ///    - detail: A closure that returns the detail view.
    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.init(
            .columnVisibilityFull(
                ColumnVisibility(columnVisibility),
                sidebar(),
                content(),
                detail()
            )
        )
    }

    /// Initializes a new instance of the split view with a sidebar and detail view.
    ///
    /// - Parameters:
    ///    - columnVisibility: A binding that controls the visibility of the sidebar column.
    ///    - sidebar: A closure that returns the sidebar view.
    ///    - detail: A closure that returns the detail view.
    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    public init(
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) where Content == EmptyView {
        self.init(
            .columnVisibility(
                ColumnVisibility(columnVisibility),
                sidebar(),
                detail()
            )
        )
    }

    /// Initializes a new instance of the split view with a sidebar, content, and detail view.
    ///
    /// This initializer does not include a binding to control the visibility of the sidebar column.
    ///
    /// - Parameters:
    ///    - sidebar: A closure that returns the sidebar view.
    ///    - content: A closure that returns the content view.
    ///    - detail: A closure that returns the detail view.
    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.init(
            .regularFull(
                sidebar(),
                content(),
                detail()
            )
        )
    }

    /// Initializes a new instance of the split view with a sidebar and detail view.
    ///
    /// This initializer does not include a binding to control the visibility of the sidebar column.
    ///
    /// - Parameters:
    ///    - sidebar: A closure that returns the sidebar view.
    ///    - detail: A closure that returns the detail view.
    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) where Content == EmptyView {
        self.init(
            .regular(
                sidebar(),
                detail()
            )
        )
    }
}
