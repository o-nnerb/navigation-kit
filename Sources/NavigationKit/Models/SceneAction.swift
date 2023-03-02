//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

public struct SceneAction {

    private let _sceneAction: _SceneAction

    init(_ _sceneAction: _SceneAction) {
        self._sceneAction = _sceneAction
    }

    public func callAsFunction<Item: Hashable>(_ item: Item) {
        _sceneAction(.init(Item.self))(item)
    }
}
