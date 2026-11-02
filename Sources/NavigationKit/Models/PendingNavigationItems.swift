// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// The items a navigation stack starts with, kept in the form each implementation needs.
struct PendingNavigationItems: Hashable {

    let hashes: [Int]

    /// The items of the fallback implementation.
    let entries: [NavigationEntry]

    /// The `NavigationPath` of the system navigation. Only built when it is available.
    private let system: Any?

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    var path: NavigationPath {
        (system as? NavigationPath) ?? NavigationPath()
    }

    init<S: Sequence>(_ sequence: S) where S.Element: Hashable {
        let entries = sequence.map { NavigationEntry($0) }
        self.hashes = entries.map(\.hash)
        self.entries = entries

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            self.system = NavigationPath(sequence)
        } else {
            self.system = nil
        }
    }

    init(_ codableRepresentation: NavigationAction.CodableRepresentation) {
        let entries = NavigationEntryCodec.decode(codableRepresentation.navigationPath) ?? []

        // `hashValue` is different on each launch of the app, so the hashes saved by another launch
        // do not find anything. The ones of the decoded items do. When some item cannot be decoded
        // the saved ones are all there is.
        let isComplete = entries.count * 2 == codableRepresentation.navigationPath.count

        self.hashes = isComplete ? entries.map(\.hash) : codableRepresentation.hashes
        self.entries = isComplete ? entries : []

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            self.system = NavigationPathCodec.path(from: codableRepresentation.navigationPath)
        } else {
            self.system = nil
        }
    }

    func hash(into hasher: inout Hasher) {
        hashes.hash(into: &hasher)
    }

    static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.hashes == rhs.hashes
    }
}
