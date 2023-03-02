//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI
import Combine

public struct SceneAction {

    private let seed = Seed()

    init() {}

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
