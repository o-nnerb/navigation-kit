//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

final class Seed: Hashable {

    static func == (_ lhs: Seed, _ rhs: Seed) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
