// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

final class Seed: Hashable, @unchecked Sendable {

    static func == (_ lhs: Seed, _ rhs: Seed) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
