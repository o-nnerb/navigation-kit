/*
 See LICENSE for this package's licensing information.
*/

import Foundation

@MainActor
protocol NavigationStateProtocol: Sendable {

    func setItems<Item: Hashable>(_ items: [Item])

    func setItems<Item: Hashable & Codable>(_ items: [Item])

    func append<Item: Hashable>(_ item: Item)

    func append<Item: Hashable & Codable>(_ item: Item)

    func removeIncluding<Item: Hashable>(_ item: Item)

    func removeUntil<Item: Hashable>(_ item: Item)

    func remove<Item: Hashable>(_ item: Item)

    func removeAll()

    func removeLast()

    func removeLast(_ k: Int)

    var count: Int { get }

    var codable: NavigationAction.CodableRepresentation? { get }

    func contains<Item: Hashable>(_ item: Item) -> Bool
}
