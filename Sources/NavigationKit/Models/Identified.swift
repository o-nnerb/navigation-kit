/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

struct Identified<Item: Hashable>: Identifiable {

    let item: Item

    var id: Int {
        item.hashValue
    }
}
