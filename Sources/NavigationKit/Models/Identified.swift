// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

struct Identified<Item: Hashable>: Identifiable {

    let item: Item

    var id: Int {
        item.hashValue
    }
}
