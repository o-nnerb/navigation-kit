//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

enum NavigationPerform {
    case setItems([NavigationItem])
    case removeIncluding(NavigationItem)
    case removeUntil(NavigationItem)
    case append(NavigationItem)
    case removeLast(Int?)
    case removeAll
}
