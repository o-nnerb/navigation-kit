//
//  File.swift
//  
//
//  Created by Brenno on 25/02/23.
//

import Foundation

class InverseResolver<Key: Hashable, Value> {

    var resolver = Resolver<Key, Value>()

    func callAsFunction(_ key: Key) -> Value {
        resolver(key)
    }

    func register(_ value: Value, forKey key: Key, with id: RegisterID) {
        resolver.register(value, forKey: key, with: id)
    }
}
