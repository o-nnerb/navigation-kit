// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

struct Factory<Value: Sendable>: Sendable {
    weak var seed: Seed?
    let value: Value

    init(_ value: Value, with seed: Seed) {
        self.seed = seed
        self.value = value
    }
}
