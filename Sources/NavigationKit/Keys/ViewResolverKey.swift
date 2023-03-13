/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

typealias _ViewResolver = Resolver<ObjectIdentifier, (AnyHashable) -> AnyView>

struct ViewResolverKey: EnvironmentKey {
    static var defaultValue: _ViewResolver?
}

extension EnvironmentValues {

    var _viewResolver: _ViewResolver? {
        get { self[ViewResolverKey.self] }
        set { self[ViewResolverKey.self] = newValue }
    }

    /// The view resolver associated with the environment.
    public var viewResolver: ViewResolver {
        guard let _viewResolver else {
            fatalError()
        }

        return .init(_viewResolver)
    }
}

extension View {

    /**
     Associates a view with a specific type of item.

     Use this method to associate a view with a specific type of item. When the view
     resolver encounters an item of the specified type, it calls the provided closure to
     create a view for the item.

     - Parameters:
        - type: The type of item to associate with the view.
        - content: The closure that creates a view for the item.
     - Returns: A modified view with a view resolver configured to handle the specified item.
     */
    public func viewResolver<Item: Hashable, Content: View>(
        for type: Item.Type,
        @ViewBuilder _ content: @escaping (Item) -> Content
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
