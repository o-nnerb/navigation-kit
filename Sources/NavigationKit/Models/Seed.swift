/*
 See LICENSE for this package's licensing information.
*/

import Foundation

final class Seed: Hashable {

    static func == (_ lhs: Seed, _ rhs: Seed) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
