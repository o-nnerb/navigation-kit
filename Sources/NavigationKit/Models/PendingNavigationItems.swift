//
//  File.swift
//  
//
//  Created by Brenno on 02/03/23.
//

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
