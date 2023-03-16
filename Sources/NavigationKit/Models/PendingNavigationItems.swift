/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

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
