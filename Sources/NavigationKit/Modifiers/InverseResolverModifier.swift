//
//  File.swift
//  
//
//  Created by Brenno on 25/02/23.
//

import SwiftUI

struct InverseResolverModifier<Key: Hashable, Value>: ViewModifier {

    typealias Resolver = InverseResolver<Key, Value>

    @Environment var resolver: Resolver?
    @State var id = RegisterID()

    private let keyPath: WritableKeyPath<EnvironmentValues, Resolver?>
    private let initClosure: (() -> Resolver)?
    private let key: Key
    private let value: Value

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
        let resolver = resolver ?? initClosure?()
        resolver?.register(value, forKey: key, with: id)
        return resolver
    }
}

extension View {

    func inverseResolver<Key: Hashable, Value>(
        keyPath: WritableKeyPath<EnvironmentValues, InverseResolver<Key, Value>?>,
        init initClosure: (() -> InverseResolver<Key, Value>)?,
        key: Key,
        value: Value
    ) -> some View {
        modifier(InverseResolverModifier(
            keyPath: keyPath,
            init: initClosure,
            key: key,
            value: value
        ))
    }
}
