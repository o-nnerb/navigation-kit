/*
 See LICENSE for this package's licensing information.
*/

import Foundation

enum NavigationPerform<Item: Hashable>: Hashable {
    case setItems([Item])
    case removeIncluding(Item)
    case removeUntil(Item)
    case append(Item)
    case remove(Item)
    case contains(Item)
}
