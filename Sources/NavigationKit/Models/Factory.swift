//
//  File.swift
//  
//
//  Created by Brenno on 25/02/23.
//

import Foundation

struct Factory<Value> {
    weak var id: RegisterID?
    let value: Value

    init(_ value: Value, with id: RegisterID) {
        self.id = id
        self.value = value
    }
}
