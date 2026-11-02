// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

struct PendingNavigationItems: Hashable {
    let path: NavigationPath
    let hashes: [Int]

    func hash(into hasher: inout Hasher) {
        hashes.hash(into: &hasher)
    }

    static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.hashes == rhs.hashes
    }
}

extension PendingNavigationItems {

    init(_ codableRepresentation: NavigationAction.CodableRepresentation) {
        self.init(
            path: .init(codableRepresentation.navigationPath),
            hashes: codableRepresentation.hashes
        )
    }
}
