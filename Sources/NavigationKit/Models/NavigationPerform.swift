// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

@MainActor
enum NavigationPerform<Item: Hashable>: Hashable {
    case setItems([Item])
    case removeIncluding(Item)
    case removeUntil(Item)
    case append(Item)
    case remove(Item)
    case contains(Item)
}
