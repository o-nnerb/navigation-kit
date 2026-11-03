// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

typealias _ViewResolver = Resolver<ObjectIdentifier, @MainActor (AnyHashable) -> AnyView>

struct ViewResolverKey: EnvironmentKey {

    static var defaultValue: _ViewResolver? {
        nil
    }
}

extension EnvironmentValues {

    var _viewResolver: _ViewResolver? {
        get { self[ViewResolverKey.self] }
        set { self[ViewResolverKey.self] = newValue }
    }

    /// Builds the view registered for a model with ``SwiftUICore/View/viewResolver(for:_:)``.
    ///
    /// Reading it from a view that has no `viewResolver(for:_:)` above it stops the program, and so
    /// does resolving a model whose type was never registered.
    ///
    /// ```swift
    /// struct Root: View {
    ///     @Environment(\.viewResolver) private var viewResolver
    ///
    ///     var body: some View {
    ///         viewResolver(ProfileScene())
    ///     }
    /// }
    /// ```
    public var viewResolver: ViewResolver {
        guard let _viewResolver else {
            fatalError()
        }

        return .init(_viewResolver)
    }
}

extension View {

    /// Associates a view with a specific type of item.
    ///
    /// When a view below this one resolves an item of that type through
    /// ``SwiftUICore/EnvironmentValues/viewResolver``, the closure builds the view that is shown.
    /// The caller only knows the model, so the view that is shown can change without touching it.
    ///
    /// ```swift
    /// ContentView()
    ///     .viewResolver(for: ProfileScene.self) {
    ///         ProfileCoordinator($0)
    ///     }
    /// ```
    ///
    /// The view built by the closure sees the same `viewResolver`, ``SwiftUICore/EnvironmentValues/sceneAction``
    /// and ``SwiftUICore/EnvironmentValues/navigationAction`` as the view that resolved it.
    ///
    /// - Parameters:
    ///    - type: The type of item to associate with the view.
    ///    - content: The closure that creates a view for the item.
    /// - Returns: A modified view with a view resolver configured to handle the specified item.
    public func viewResolver<Item: Hashable & Sendable, Content: View>(
        for type: Item.Type,
        @ViewBuilder _ content: @escaping @MainActor (Item) -> Content
    ) -> some View {
        resolver(
            keyPath: \._viewResolver,
            init: { .init() },
            key: ObjectIdentifier(type),
            value: {
                guard let input = $0 as? Item else {
                    fatalError()
                }

                return AnyView(content(input))
            }
        )
    }
}
