/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/// A type that transforms a navigation destination to a specific item.
public struct NavigationDestinationTransformer {

    private let state: State

    init(_ action: Action) {
        state = .init(action)
    }

    /// Transforms the navigation destination for the specified item.
    ///
    /// - Parameter item: The item transformed.
    public func callAsFunction<Item: Hashable>(_ item: Item) {
        state.send(item)
    }

    func perform(_ navigationAction: NavigationAction) {
        state.perform(navigationAction)
    }
}

extension NavigationDestinationTransformer {

    fileprivate class State {

        private var transformer: (() -> AnyHashable)?
        private var executor: ((NavigationAction) -> Void)?

        private let action: NavigationDestinationTransformer.Action

        init(_ action: NavigationDestinationTransformer.Action) {
            self.action = action
        }

        private func transaction<Item: Hashable>(
            for type: Item.Type,
            transform: @escaping (Item?) -> Item,
            execute: @escaping (NavigationAction, Item) -> Void
        ) {
            transformer = { [transformer] in
                transform(transformer?() as? Item)
            }
            executor = { [transformer] in
                guard let item = transformer?() as? Item else {
                    fatalError()
                }

                execute($0, item)
            }
        }

        func send<Item: Hashable>(_ item: Item) {
            switch action {
            case .append:
                transaction(
                    for: Item.self,
                    transform: { _ in item },
                    execute: { $0.append($1) }
                )
            case .setItems:
                transaction(
                    for: [Item].self,
                    transform: { ($0 ?? []) + [item] },
                    execute: { $0.setItems($1) }
                )
            case .removeUntil:
                transaction(
                    for: Item.self,
                    transform: { _ in item },
                    execute: { $0.removeUntil($1) }
                )
            case .removeIncluding:
                transaction(
                    for: Item.self,
                    transform: { _ in item },
                    execute: { $0.removeIncluding($1) }
                )
            }
        }

        func perform(_ navigationAction: NavigationAction) {
            executor?(navigationAction)
        }
    }
}

extension NavigationDestinationTransformer {

    enum Action {
        case append
        case setItems
        case removeUntil
        case removeIncluding
    }
}
