//
//  File.swift
//  
//
//  Created by Brenno on 25/02/23.
//

import Foundation

struct Factory<Value> {
    weak var seed: Seed?
    let value: Value

    init(_ value: Value, with seed: Seed) {
        self.seed = seed
        self.value = value
    }
}
