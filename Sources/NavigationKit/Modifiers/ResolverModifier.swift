//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

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
            .environment(keyPath, updatedResolver())
    }

    func updatedResolver() -> Resolver? {
        var resolver = resolver ?? initClosure?()

        resolver?.register(value, forKey: key, with: seed)

        return resolver
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
