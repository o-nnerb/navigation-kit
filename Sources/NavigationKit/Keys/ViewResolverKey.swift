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

    public var viewResolver: ViewResolver {
        guard let _viewResolver else {
            fatalError()
        }

        return .init(_viewResolver)
    }
}

extension View {

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
