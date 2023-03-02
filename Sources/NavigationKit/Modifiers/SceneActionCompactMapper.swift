//
//  File.swift
//
//
//  Created by Brenno on 02/03/23.
//

import SwiftUI
import Combine

private struct SceneActionCompactMapper<Action: Hashable, NewAction: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    private let mapper: (Action) -> NewAction?

    init(mapper: @escaping (Action) -> NewAction?) {
        self.mapper = mapper
    }

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Action.self) {
                if let newAction = mapper($0) {
                    sceneAction(newAction)
                }
            }
    }
}

extension View {

    public func sceneActionCompactMap<Action: Hashable, NewAction: Hashable>(
        for actionType: Action.Type,
        _ mapper: @escaping (Action) -> NewAction?
    ) -> some View {
        modifier(SceneActionCompactMapper(mapper: mapper))
    }
}
