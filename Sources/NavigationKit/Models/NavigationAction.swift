//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI
import Combine

public struct NavigationAction {

    private let state: NavigationState

    init(_ state: NavigationState) {
        self.state = state
    }
}

extension NavigationAction {

    public func removeIncluding<Item: Hashable>(_ item: Item) {
        state.removeIncluding(item)
    }

    public func removeUntil<Item: Hashable>(_ item: Item) {
        state.removeUntil(item)
    }

    public func append<Item: Hashable>(_ item: Item) {
        state.append(item)
    }

    public func setItems<Item: Hashable>(_ items: [Item]) {
        state.setItems(items)
    }

    public func removeAll() {
        state.removeAll()
    }

    public func removeLast() {
        state.removeLast()
    }

    public func removeLast(_ k: Int) {
        state.removeLast(k)
    }

    public var count: Int {
        state.count
    }
}
