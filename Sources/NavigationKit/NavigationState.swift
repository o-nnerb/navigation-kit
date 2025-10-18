/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

@MainActor
final class NavigationState: ObservableObject {

    private var _path = NavigationPath()
    private var restore: [Int: () -> Void] = [:]
    private var hashes: [Int] = []
    private var lastPendingNavigationItemsHashValue: Int?

    private var isLock = false
    private var cancellations: [AnyCancellable] = []

    var path: NavigationPath {
        get { _path }
        set {
            _path = newValue
            if !isLock {
                objectWillChange.send()
            }
        }
    }

    init() {
        objectWillChange.sink { [weak self] in
            self?.updateHashes()
        }.store(in: &cancellations)
    }

    subscript(_ pendingItems: PendingNavigationItems?) -> NavigationPath {
        get {
            updatePendingItems(pendingItems)
            return path
        }
        set { path = newValue }
    }

    private func updatePendingItems(_ pendingItems: PendingNavigationItems?) {
        let hashValue = pendingItems?.hashValue

        guard lastPendingNavigationItemsHashValue != hashValue else {
            return
        }

        lastPendingNavigationItemsHashValue = hashValue
        hashes = pendingItems?.hashes ?? []
        _path = pendingItems?.path ?? .init()
    }

    private func updateHashes() {
        hashes = Array(hashes[0 ..< path.count])
    }
}

// MARK: - NavigationStateProtocol

extension NavigationState: NavigationStateProtocol {

    func setItems<Item: Hashable>(_ items: [Item]) {
        for item in items {
            restore[item.hashValue] = { [weak self] in
                self?.append(item)
            }
        }

        self.hashes = items.map(\.hashValue)
        path = .init(items)
    }

    func setItems<Item: Hashable & Codable>(_ items: [Item]) {
        for item in items {
            restore[item.hashValue] = { [weak self] in
                self?.append(item)
            }
        }

        self.hashes = items.map(\.hashValue)
        path = .init(items)
    }

    func append<Item: Hashable>(_ item: Item) {
        restore[item.hashValue] = { [weak self] in
            self?.append(item)
        }

        hashes.append(item.hashValue)
        path.append(item)
    }

    func append<Item: Hashable & Codable>(_ item: Item) {
        restore[item.hashValue] = { [weak self] in
            self?.append(item)
        }

        hashes.append(item.hashValue)
        path.append(item)
    }

    func removeIncluding<Item: Hashable>(_ item: Item) {
        guard let index = hashes.firstIndex(of: item.hashValue) else {
            return
        }

        for hash in hashes[index ..< hashes.endIndex] {
            restore[hash] = nil
        }

        let k = path.count - index
        hashes.removeLast(k)
        path.removeLast(k)
    }

    func removeUntil<Item: Hashable>(_ item: Item) {
        guard let index = hashes.firstIndex(of: item.hashValue) else {
            return
        }

        for hash in hashes[index + 1 ..< hashes.endIndex] {
            restore[hash] = nil
        }

        let k = path.count - (index + 1)
        hashes.removeLast(k)
        path.removeLast(k)
    }

    func remove<Item: Hashable>(_ item: Item) {
        guard let index = hashes.firstIndex(of: item.hashValue) else {
            return
        }

        let hash = hashes.remove(at: index)
        restore[hash] = nil

        _path = .init()

        isLock = true
        for hash in hashes {
            restore[hash]?()
        }
        isLock = false

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            path = _path
        }
    }

    func removeAll() {
        restore = [:]
        hashes.removeLast(hashes.count)
        path.removeLast(path.count)
    }

    func removeLast() {
        let hash = hashes.removeLast()
        restore[hash] = nil
        path.removeLast()
    }

    func removeLast(_ k: Int) {
        let index = hashes.index(hashes.endIndex, offsetBy: -k)
        for hash in hashes[index ..< hashes.endIndex] {
            restore[hash] = nil
        }

        hashes.removeLast(k)
        path.removeLast(k)
    }

    var count: Int {
        path.count
    }

    var codable: NavigationAction.CodableRepresentation? {
        path.codable.map {
            .init(
                navigationPath: $0,
                hashes: hashes
            )
        }
    }

    func contains<Item: Hashable>(_ item: Item) -> Bool {
        hashes.contains(item.hashValue)
    }
}
