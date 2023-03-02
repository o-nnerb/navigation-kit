//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

typealias _SceneAction = Resolver<ObjectIdentifier, (AnyHashable) -> Void>

struct SceneActionKey: EnvironmentKey {
    static var defaultValue: _SceneAction?
}

extension EnvironmentValues {

    var _sceneAction: _SceneAction? {
        get { self[SceneActionKey.self] }
        set { self[SceneActionKey.self] = newValue }
    }

    public var sceneAction: SceneAction {
        guard let _sceneAction else {
            fatalError()
        }

        return .init(_sceneAction)
    }
}

extension View {

    public func sceneAction<Item: Hashable>(
        for type: Item.Type,
        closure: @escaping (Item) -> Void
    ) -> some View {
        resolver(
            keyPath: \._sceneAction,
            init: { .init() },
            key: ObjectIdentifier(type),
            value: {
                guard let input = $0 as? Item else {
                    fatalError()
                }

                return closure(input)
            }
        )
    }
}
