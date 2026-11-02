// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Combine
import SwiftUI

/// A type that transforms a scene action to a specific item.
public struct SceneActionTransformer {

    private let state: State

    init() {
        state = .init()
    }

    /// Transforms the scene action for the specified item.
    ///
    /// - Parameter item: The item transformed.
    public func callAsFunction<Item: Hashable>(_ item: Item) {
        state.send(item)
    }

    func perform(_ sceneAction: SceneAction) {
        state.perform(sceneAction)
    }
}

extension SceneActionTransformer {

    fileprivate class State {

        private var executor: ((SceneAction) -> Void)?

        private func transaction<Item>(
            _ item: Item,
            execute: @escaping (SceneAction, Item) -> Void
        ) {
            executor = {
                execute($0, item)
            }
        }

        func perform(_ sceneAction: SceneAction) {
            executor?(sceneAction)
        }
    }
}

extension SceneActionTransformer.State {

    func send<Item: Hashable>(_ item: Item) {
        transaction(
            item,
            execute: {
                $0($1)
            }
        )
    }
}
