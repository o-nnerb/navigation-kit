/*
 See LICENSE for this package's licensing information.
*/

import Foundation
import SwiftUI
@testable import NavigationKit

class NavigationStateMock: NavigationStateProtocol {

    private(set) var stack = [AnyHashable]()

    func setItems<Item: Hashable>(_ items: [Item]) {
        stack = items
    }

    func setItems<Item: Hashable & Codable>(_ items: [Item]) {
        stack = items
    }

    func append<Item: Hashable>(_ item: Item) {
        stack.append(item)
    }

    func append<Item: Hashable & Codable>(_ item: Item) {
        stack.append(item)
    }

    func removeIncluding<Item: Hashable>(_ item: Item) {
        guard let index = stack.firstIndex(of: item) else {
            return
        }

        stack.removeLast(stack.count - index)
    }

    func removeUntil<Item: Hashable>(_ item: Item) {
        guard let index = stack.firstIndex(of: item) else {
            return
        }

        stack.removeLast(stack.count - (index + 1))
    }

    func remove<Item: Hashable>(_ item: Item) {
        guard let index = stack.firstIndex(of: item) else {
            return
        }

        stack.remove(at: index)
    }

    func removeAll() {
        stack = []
    }

    func removeLast() {
        stack.removeLast()
    }

    func removeLast(_ k: Int) {
        stack.removeLast(k)
    }

    var count: Int {
        stack.count
    }

    var codable: NavigationAction.CodableRepresentation? {
        var navigationPath = NavigationPath()

        for item in stack {
            navigationPath.append(item)
        }

        return navigationPath.codable.map {
            .init(
                navigationPath: $0,
                hashes: stack.map(\.hashValue)
            )
        }
    }

    func contains<Item: Hashable>(_ item: Item) -> Bool {
        stack.contains(item)
    }
}
