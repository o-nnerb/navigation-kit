// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Passed to the closure of ``SwiftUICore/View/sceneActionTransformer(for:_:)`` to send another action
/// in response to the one received.
public struct SceneActionTransformer {

    private let state: State

    init() {
        state = .init()
    }

    /// Sends the item as an action of the scene.
    ///
    /// The action that was received is not removed from the scene, so its other handlers still get it.
    /// Not calling this method sends nothing.
    ///
    /// - Parameter item: The action to send.
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
