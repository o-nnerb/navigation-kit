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
        self.hashes = sequence.map(\.hashValue)
        self.entries = sequence.map { NavigationEntry($0) }

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            self.system = NavigationPath(sequence)
        } else {
            self.system = nil
        }
    }

    init(_ codableRepresentation: NavigationAction.CodableRepresentation) {
        self.hashes = codableRepresentation.hashes
        self.entries = NavigationEntryCodec.decode(codableRepresentation.navigationPath) ?? []

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
