/*
 See LICENSE for this package's licensing information.
*/

import Foundation

struct Factory<Value> {
    weak var seed: Seed?
    let value: Value

    init(_ value: Value, with seed: Seed) {
        self.seed = seed
        self.value = value
    }
}
