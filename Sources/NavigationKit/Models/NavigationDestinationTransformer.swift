/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/// A type that transforms a navigation destination to a specific item.
@MainActor
public struct NavigationDestinationTransformer: Sendable {

    private let state: State

    init(_ action: Action) {
        state = .init(action)
    }

    /// Transforms the navigation destination for the specified item.
    ///
    /// - Parameter item: The item transformed.
    public func callAsFunction<Item: Hashable & Sendable>(_ item: Item) {
        state.send(item)
    }

    /// Transforms the navigation destination for the specified `Codable` item.
    ///
    /// - Parameter item: The item transformed.
    public func callAsFunction<Item: Hashable & Codable & Sendable>(_ item: Item) {
        state.send(item)
    }

    @discardableResult
    func perform(_ navigationAction: NavigationAction) -> Any? {
        state.perform(navigationAction)
    }
}

extension NavigationDestinationTransformer {

    @MainActor
    fileprivate class State {

        private var transformer: (@MainActor () -> Any)?
        private var executor: (@MainActor (NavigationAction) -> Any)?

        private let action: NavigationDestinationTransformer.Action

        init(_ action: NavigationDestinationTransformer.Action) {
            self.action = action
        }

        private func transaction<Item>(
            for type: Item.Type,
            transform: @escaping @MainActor (Item?) -> Item,
            execute: @escaping @MainActor (NavigationAction, Item) -> Void
        ) {
            transformer = { [transformer] in
                transform(transformer?() as? Item)
            }
            executor = { [transformer] in
                guard let item = transformer?() as? Item else {
                    fatalError()
                }

                execute($0, item)
                return item
            }
        }

        func perform(_ navigationAction: NavigationAction) -> Any? {
            executor?(navigationAction)
        }
    }
}

extension NavigationDestinationTransformer.State {

    private func setItemsTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: [Item].self,
            transform: { ($0 ?? []) + [item] },
            execute: { $0.setItems($1) }
        )
    }

    private func setItemsTransaction<Item: Hashable & Codable & Sendable>(_ item: Item) {
        transaction(
            for: [Item].self,
            transform: { ($0 ?? []) + [item] },
            execute: { $0.setItems($1) }
        )
    }

    private func appendTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { $0.append($1) }
        )
    }

    private func appendTransaction<Item: Hashable & Codable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { $0.append($1) }
        )
    }

    private func removeUntilTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { $0.removeUntil($1) }
        )
    }

    private func removeIncludingTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { $0.removeIncluding($1) }
        )
    }

    private func removeTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { $0.remove($1) }
        )
    }

    private func containsTransaction<Item: Hashable & Sendable>(_ item: Item) {
        transaction(
            for: Item.self,
            transform: { _ in item },
            execute: { _, _ in }
        )
    }

    func send<Item: Hashable & Sendable>(_ item: Item) {
        switch action {
        case .setItems:
            setItemsTransaction(item)
        case .append:
            appendTransaction(item)
        case .removeUntil:
            removeUntilTransaction(item)
        case .removeIncluding:
            removeIncludingTransaction(item)
        case .remove:
            removeTransaction(item)
        case .contains:
            containsTransaction(item)
        }
    }

    func send<Item: Hashable & Codable & Sendable>(_ item: Item) {
        switch action {
        case .setItems:
            setItemsTransaction(item)
        case .append:
            appendTransaction(item)
        case .removeUntil:
            removeUntilTransaction(item)
        case .removeIncluding:
            removeIncludingTransaction(item)
        case .remove:
            removeTransaction(item)
        case .contains:
            containsTransaction(item)
        }
    }
}

extension NavigationDestinationTransformer {

    enum Action {
        case append
        case setItems
        case removeUntil
        case removeIncluding
        case remove
        case contains
    }
}
