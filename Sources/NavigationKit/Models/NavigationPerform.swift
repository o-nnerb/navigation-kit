//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

enum NavigationPerform<Item: Hashable>: Hashable {
    case setItems([Item])
    case removeIncluding(Item)
    case removeUntil(Item)
    case append(Item)
}
