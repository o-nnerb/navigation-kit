/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

/**
 A type that represents an action that can be performed on a scene.

 You can use this type to define custom actions that can be triggered on a scene. It takes a generic
 `Action` parameter that conforms to the `Hashable` protocol.

 You can then call the `callAsFunction` method on an instance of `SceneAction` with an
 argument of type `Action` to perform the corresponding action available in the scene.
 */
public struct SceneAction: Sendable {

    private let seed = Seed()

    init() {}

    /**
     Perform the action associated with this `SceneAction`.

     Call this method with an argument of type `Action` to perform the corresponding
     action on the scene.

     - Parameter action: The action to perform on the scene.
     */
    public func callAsFunction<Action: Hashable>(_ action: Action) {
        NotificationCenter.default.post(
            name: .init("\(ObjectIdentifier(Action.self))"),
            object: seed,
            userInfo: ["action": action]
        )
    }
}

extension SceneAction {

    func publisher<Action: Hashable>(for actionType: Action.Type) -> AnyPublisher<Action, Never> {
        NotificationCenter.default.publisher(
            for: .init("\(ObjectIdentifier(actionType))"),
            object: seed
        )
        .flatMap { notification -> AnyPublisher<Action, Never> in
            guard let action = notification.userInfo?["action"] as? Action else {
                return Empty(outputType: Action.self, failureType: Never.self)
                    .eraseToAnyPublisher()
            }

            return Just(action).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
