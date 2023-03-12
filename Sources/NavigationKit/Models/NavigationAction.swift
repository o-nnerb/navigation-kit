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
    private let resolver: [ObjectIdentifier: (AnyHashable) -> Void]

    private init(
        state: NavigationState,
        resolver: [ObjectIdentifier: (AnyHashable) -> Void]
    ) {
        self.state = state
        self.resolver = resolver
    }

    init(_ state: NavigationState) {
        self.init(state: state, resolver: [:])
    }
}

extension NavigationAction {

    public func removeIncluding<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeIncluding(item)) {
            return
        }

        state.removeIncluding(item)
    }

    public func removeUntil<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeUntil(item)) {
            return
        }

        state.removeUntil(item)
    }

    public func append<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) {
            return
        }

        state.append(item)
    }

    public func setItems<Item: Hashable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) {
            return
        }

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

extension NavigationAction {

    func resolver<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationPerform<Item>) -> Void
    ) -> Self {
        guard resolver[.init(itemType)] == nil else {
            print("Resolver for \(itemType) already register")
            return self
        }

        var resolver = resolver
        resolver[.init(itemType)] = {
            guard let item = $0 as? NavigationPerform<Item> else {
                fatalError()
            }

            closure(item)
        }

        return .init(
            state: state,
            resolver: resolver
        )
    }
}

extension NavigationAction {

    fileprivate func performIfNeeded<Item: Hashable>(
        for action: NavigationPerform<Item>
    ) -> Bool {
        guard let closure = resolver[.init(Item.self)] else {
            return false
        }

        closure(action)
        return true
    }
}
