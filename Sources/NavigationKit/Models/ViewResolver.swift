/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

/// A type that resolves an item to a view.
public struct ViewResolver {

    private let _viewResolver: _ViewResolver

    init(_ _viewResolver: _ViewResolver) {
        self._viewResolver = _viewResolver
    }

    /// Returns a view for the specified item.
    ///
    /// - Parameter item: The item to resolve.
    ///
    /// - Returns: A view for the specified item.
    public func callAsFunction<Item: Hashable>(_ item: Item) -> some View {
        _viewResolver(ObjectIdentifier(Item.self))(item)
    }
}
