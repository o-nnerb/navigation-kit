// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Turns a model into the view registered for its type.
///
/// Get one from the `viewResolver` environment value and call it with the model. The views are
/// registered with ``SwiftUICore/View/viewResolver(for:_:)``.
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
public struct ViewResolver: Sendable {

    private let _viewResolver: _ViewResolver

    init(_ _viewResolver: _ViewResolver) {
        self._viewResolver = _viewResolver
    }

    /// Returns the view registered for the type of the item.
    ///
    /// Stops the program when no view was registered for that type.
    ///
    /// - Parameter item: The item to resolve.
    ///
    /// - Returns: A view for the specified item.
    @MainActor
    public func callAsFunction<Item: Hashable>(_ item: Item) -> some View {
        _viewResolver(ObjectIdentifier(Item.self))(item)
    }
}
