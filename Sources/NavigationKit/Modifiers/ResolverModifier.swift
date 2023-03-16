/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

struct ResolverModifier<Key: Hashable, Value>: ViewModifier {

    typealias Resolver = NavigationKit.Resolver<Key, Value>

    @Environment var resolver: Resolver?

    private let keyPath: WritableKeyPath<EnvironmentValues, Resolver?>
    private let initClosure: (() -> Resolver)?
    private let key: Key
    private let value: Value

    @State var seed = Seed()

    init(
        keyPath: WritableKeyPath<EnvironmentValues, Resolver?>,
        init initClosure: (() -> Resolver)?,
        key: Key,
        value: Value
    ) {
        _resolver = .init(keyPath)
        self.keyPath = keyPath
        self.initClosure = initClosure
        self.key = key
        self.value = value
    }

    func body(content: Content) -> some View {
        content
            .environment(keyPath, makeEngine().build())
    }
}

extension ResolverModifier {

    struct Engine {
        let resolver: Resolver?

        let initClosure: (() -> Resolver)?
        let key: Key
        let value: Value

        let seed = Seed()

        func build() -> Resolver? {
            var resolver = resolver ?? initClosure?()

            resolver?.register(value, forKey: key, with: seed)

            return resolver
        }
    }

    func makeEngine() -> Engine {
        Engine(
            resolver: resolver,
            initClosure: initClosure,
            key: key,
            value: value
        )
    }
}

extension View {

    func resolver<Key: Hashable, Value>(
        keyPath: WritableKeyPath<EnvironmentValues, Resolver<Key, Value>?>,
        init initClosure: (() -> Resolver<Key, Value>)?,
        key: Key,
        value: Value
    ) -> some View {
        modifier(ResolverModifier(
            keyPath: keyPath,
            init: initClosure,
            key: key,
            value: value
        ))
    }
}
