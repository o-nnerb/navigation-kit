//
//  File.swift
//  
//
//  Created by Brenno on 26/02/23.
//

import SwiftUI
import Combine

class NavigationState: ObservableObject {

    private var _path = NavigationPath()
    private var hashes: [Int] = []
    private var lastPendingNavigationItemsHashValue: Int?

    private var cancellations: [AnyCancellable] = []

    var path: NavigationPath {
        get { _path }
        set {
            _path = newValue
            objectWillChange.send()
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

extension NavigationState {

    func removeIncluding<Item: Hashable>(_ item: Item) {
        guard let index = hashes.firstIndex(of: item.hashValue) else {
            return
        }

        let k = path.count - index
        hashes.removeLast(k)
        path.removeLast(k)
    }

    func removeUntil<Item: Hashable>(_ item: Item) {
        guard let index = hashes.firstIndex(of: item.hashValue) else {
            return
        }

        let k = path.count - (index + 1)
        hashes.removeLast(k)
        path.removeLast(k)
    }

    func append<Item: Hashable>(_ item: Item) {
        hashes.append(item.hashValue)
        path.append(item)
    }

    func setItems<Item: Hashable>(_ items: [Item]) {
        hashes = items.map(\.hashValue)
        path = .init(items)
    }

    func removeAll() {
        hashes.removeLast(hashes.count)
        path.removeLast(path.count)
    }

    func removeLast() {
        hashes.removeLast()
        path.removeLast()
    }

    func removeLast(_ k: Int) {
        hashes.removeLast(k)
        path.removeLast(k)
    }

    var count: Int {
        path.count
    }
}
